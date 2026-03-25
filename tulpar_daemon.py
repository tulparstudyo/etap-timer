#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Tulpar Daemon — Oturum ve kapatma zamanlayıcısı, masaüstü sayacı."""

import fcntl
import logging
import os
import signal
import subprocess
import sys
import time
from datetime import datetime

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GLib

# --- Sabitler ---
CONFIG_PATH = "/etc/tulpar/tulpar.conf"
LOG_DIR = os.path.expanduser("~/.config/tulpar")
LOG_PATH = os.path.join(LOG_DIR, "tulpar.log")
LOCK_PATH = os.path.join(LOG_DIR, "tulpar.lock")

DEFAULT_SESSION_DURATION = 0   # dakika, 0 = devre dışı
DEFAULT_IDLE_DURATION = 0      # dakika, 0 = devre dışı
DEFAULT_TURNOFF_TIME = ""      # HH:MM, boş = devre dışı

CHECK_INTERVAL_SEC = 30        # ana döngü kontrol aralığı (saniye)
DISPLAY_UPDATE_SEC = 10        # sayaç güncelleme aralığı (saniye)

EXEMPT_USER = "etapadmin"      # bu kullanıcıda oturum/kapatma uygulanmaz


# --- Logging ---
os.makedirs(LOG_DIR, exist_ok=True)
logging.basicConfig(
    filename=LOG_PATH,
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("tulpar")


# --- Yardımcı fonksiyonlar ---
def read_config() -> dict:
    """Konfigürasyon dosyasını okur, varsayılanlarla birleştirir."""
    config = {
        "SESSION_DURATION": DEFAULT_SESSION_DURATION,
        "IDLE_DURATION": DEFAULT_IDLE_DURATION,
        "TURNOFF_TIME": DEFAULT_TURNOFF_TIME,
    }
    if not os.path.isfile(CONFIG_PATH):
        log.warning("Konfigürasyon dosyası bulunamadı: %s", CONFIG_PATH)
        return config
    try:
        with open(CONFIG_PATH, "r") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    key, value = line.split("=", 1)
                    key = key.strip()
                    value = value.strip().strip('"').strip("'")
                    if key in ("SESSION_DURATION", "IDLE_DURATION"):
                        config[key] = int(value) if value else 0
                    elif key == "TURNOFF_TIME":
                        # Boş, "0" veya "00:00" ise devre dışı say
                        if value in ("", "0", "00:00"):
                            config[key] = ""
                        else:
                            config[key] = value
    except Exception as e:
        log.error("Konfigürasyon okuma hatası: %s", e)
    return config


def get_idle_ms() -> int:
    """xprintidle ile kullanıcı idle süresini milisaniye olarak döndürür."""
    try:
        result = subprocess.run(
            ["xprintidle"], capture_output=True, text=True, timeout=5
        )
        return int(result.stdout.strip())
    except Exception:
        return 0


def logout_session() -> None:
    """Kullanıcı oturumunu kapatır."""
    log.info("Oturum kapatılıyor.")
    try:
        subprocess.Popen(["xfce4-session-logout", "--logout", "--fast"])
    except FileNotFoundError:
        try:
            subprocess.Popen(["loginctl", "terminate-session", ""])
        except Exception as e:
            log.error("Oturum kapatma hatası: %s", e)


def poweroff_system() -> None:
    """Sistemi kapatır."""
    log.info("Sistem kapatılıyor.")
    try:
        subprocess.Popen(["systemctl", "poweroff"])
    except Exception as e:
        log.error("Sistem kapatma hatası: %s", e)


def format_remaining(seconds: int) -> str:
    """Kalan saniyeyi SS:DD formatına çevirir."""
    if seconds <= 0:
        return "00:00"
    hours = seconds // 3600
    minutes = (seconds % 3600)+1 // 60
    return f"{hours:02d}:{minutes:02d}"


# --- Single Instance ---
lock_file = None


def acquire_lock() -> bool:
    """Lock dosyası ile single instance kontrolü."""
    global lock_file
    try:
        lock_file = open(LOCK_PATH, "w")
        fcntl.flock(lock_file, fcntl.LOCK_EX | fcntl.LOCK_NB)
        lock_file.write(str(os.getpid()))
        lock_file.flush()
        return True
    except (IOError, OSError):
        log.warning("Başka bir Tulpar instance zaten çalışıyor.")
        return False


def release_lock() -> None:
    """Lock dosyasını serbest bırakır."""
    global lock_file
    if lock_file:
        try:
            fcntl.flock(lock_file, fcntl.LOCK_UN)
            lock_file.close()
            os.remove(LOCK_PATH)
        except Exception:
            pass


# --- Overlay Sayaç Penceresi ---
class CountdownOverlay(Gtk.Window):
    """Masaüstünde kalan süreyi gösteren küçük overlay pencere. Sürüklenebilir."""

    def __init__(self):
        super().__init__(type=Gtk.WindowType.POPUP)
        self.set_decorated(False)
        self.set_keep_above(True)
        self.set_skip_taskbar_hint(True)
        self.set_skip_pager_hint(True)
        self.set_accept_focus(False)
        self.set_resizable(False)

        # Sürükleme durumu
        self._dragging = False
        self._drag_x = 0
        self._drag_y = 0
        self._user_positioned = False

        # CSS ile opaklık ve font ayarı
        css = Gtk.CssProvider()
        css.load_from_data(b"""
            window { opacity: 0.85; }
            label { font: bold 14px monospace; padding: 4px 8px; }
        """)
        Gtk.StyleContext.add_provider_for_screen(
            self.get_screen(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        # Event box ile fare olaylarını yakala
        self.event_box = Gtk.EventBox()
        self.event_box.connect("button-press-event", self._on_button_press)
        self.event_box.connect("button-release-event", self._on_button_release)
        self.event_box.connect("motion-notify-event", self._on_motion)
        self.add(self.event_box)

        self.label = Gtk.Label(label="--:--")
        self.event_box.add(self.label)

        # Ekranın sağ alt köşesine konumla
        self.connect("realize", self._on_realize)
        self.show_all()

    def _on_realize(self, widget):
        self._reposition()

    def _reposition(self):
        """Kullanıcı sürüklemediyse sağ alt köşeye konumla."""
        if self._user_positioned:
            return
        display = self.get_display()
        monitor = display.get_primary_monitor()
        if monitor is None:
            monitor = display.get_monitor(0)
        geom = monitor.get_geometry()
        # show_all sonrası boyutu almak için size_request kullan
        req = self.get_preferred_size()[1]
        w = max(req.width, 80)
        h = max(req.height, 30)
        x = geom.x + geom.width - w - 20
        y = geom.y + geom.height - h - 60  # panel yüksekliği için pay
        self.move(x, y)

    def _on_button_press(self, widget, event):
        if event.button == 1:
            self._dragging = True
            self._drag_x = int(event.x_root)
            self._drag_y = int(event.y_root)

    def _on_button_release(self, widget, event):
        if event.button == 1:
            self._dragging = False
            self._user_positioned = True

    def _on_motion(self, widget, event):
        if self._dragging:
            pos = self.get_position()
            dx = int(event.x_root) - self._drag_x
            dy = int(event.y_root) - self._drag_y
            self.move(pos[0] + dx, pos[1] + dy)
            self._drag_x = int(event.x_root)
            self._drag_y = int(event.y_root)

    def update_text(self, text: str) -> None:
        self.label.set_text(text)
        if not self._user_positioned:
            self._reposition()


# --- Ana Daemon Sınıfı ---
class TulparDaemon:
    """Ana daemon mantığı."""

    def __init__(self):
        self.config = read_config()
        self.session_start = time.monotonic()
        self.running = True
        self.overlay = CountdownOverlay()

        # TURNOFF_TIME sonrası başlatma kontrolü:
        # Daemon, TURNOFF_TIME saatinden sonra başlatıldıysa (aynı gün)
        # tüm zamanlayıcılar devre dışı kalır.
        self.bypassed = False
        tt = self.config["TURNOFF_TIME"]
        if tt:
            try:
                now_dt = datetime.now()
                target = datetime.strptime(tt, "%H:%M").replace(
                    year=now_dt.year, month=now_dt.month, day=now_dt.day
                )
                if now_dt >= target:
                    self.bypassed = True
                    log.info(
                        "Daemon TURNOFF_TIME (%s) sonrası başlatıldı, "
                        "zamanlayıcılar devre dışı.",
                        tt,
                    )
            except ValueError:
                pass

        # Sinyal yakalama
        signal.signal(signal.SIGTERM, self._handle_signal)
        signal.signal(signal.SIGHUP, self._handle_signal)
        signal.signal(signal.SIGINT, self._handle_signal)

        log.info(
            "Tulpar daemon başlatıldı. SESSION=%d dk, IDLE=%d dk, TURNOFF=%s, bypassed=%s",
            self.config["SESSION_DURATION"],
            self.config["IDLE_DURATION"],
            self.config["TURNOFF_TIME"] or "devre dışı",
            self.bypassed,
        )

    def _handle_signal(self, signum, frame):
        log.info("Sinyal alındı (%s), kapatılıyor.", signum)
        self.running = False
        release_lock()
        Gtk.main_quit()

    def _calc_remaining_seconds(self) -> tuple[int, str] | None:
        """Aktif sayaçlardan en yakın olanın kalan süresini ve kaynağını hesaplar."""
        # Bypass modunda sayaç gösterme
        if self.bypassed:
            return None

        candidates = []
        now_mono = time.monotonic()

        # SESSION_DURATION
        sd = self.config["SESSION_DURATION"]
        if sd > 0:
            elapsed = now_mono - self.session_start
            left = (sd * 60) - elapsed
            candidates.append((left, "Oturum"))

        # TURNOFF_TIME
        tt = self.config["TURNOFF_TIME"]
        if tt:
            try:
                now_dt = datetime.now()
                target = datetime.strptime(tt, "%H:%M").replace(
                    year=now_dt.year, month=now_dt.month, day=now_dt.day
                )
                left = (target - now_dt).total_seconds()
                if left > 0:
                    candidates.append((left, "Kapanma"))
                else:
                    candidates.append((0, "Kapanma"))
            except ValueError:
                pass

        if candidates:
            closest = min(candidates, key=lambda x: x[0])
            return (max(0, int(closest[0])), closest[1])
        return None

    def _check_timers(self) -> bool:
        """Zamanlayıcıları kontrol eder. Aksiyon gerekirse çalıştırır."""
        # Muaf kullanıcı kontrolü
        current_user = os.environ.get("USER", "")
        if current_user == EXEMPT_USER:
            return True

        # TURNOFF_TIME sonrası başlatıldıysa tüm zamanlayıcılar devre dışı
        if self.bypassed:
            return True

        now_mono = time.monotonic()

        # SESSION_DURATION kontrolü
        sd = self.config["SESSION_DURATION"]
        if sd > 0:
            elapsed = now_mono - self.session_start
            if elapsed >= sd * 60:
                log.info("SESSION_DURATION doldu (%d dk).", sd)
                logout_session()
                return False

        # IDLE_DURATION kontrolü
        idle_dur = self.config["IDLE_DURATION"]
        if idle_dur > 0:
            idle_ms = get_idle_ms()
            if idle_ms >= idle_dur * 60 * 1000:
                log.info("IDLE_DURATION doldu (%d dk, idle=%d ms).", idle_dur, idle_ms)
                logout_session()
                return False

        # TURNOFF_TIME kontrolü
        tt = self.config["TURNOFF_TIME"]
        if tt:
            try:
                now_dt = datetime.now()
                target = datetime.strptime(tt, "%H:%M").replace(
                    year=now_dt.year, month=now_dt.month, day=now_dt.day
                )
                if now_dt >= target:
                    log.info("TURNOFF_TIME geçildi (%s).", tt)
                    poweroff_system()
                    return False
            except ValueError:
                log.error("TURNOFF_TIME format hatası: %s", tt)

        return True

    def _tick(self) -> bool:
        """GLib.timeout_add ile periyodik çağrılır."""
        if not self.running:
            return False

        # Zamanlayıcıları kontrol et
        if not self._check_timers():
            self.running = False
            GLib.timeout_add(2000, Gtk.main_quit)
            return False

        # Overlay güncelle
        result = self._calc_remaining_seconds()
        if result is not None:
            seconds, source = result
            self.overlay.update_text(f"{source} {format_remaining(seconds)}")
        else:
            self.overlay.update_text("--:--")

        return True  # tekrar çağrılsın

    def run(self) -> None:
        """Daemon ana döngüsünü başlatır."""
        # İlk güncelleme
        self._tick()
        # Periyodik kontrol
        GLib.timeout_add_seconds(CHECK_INTERVAL_SEC, self._tick)
        Gtk.main()


# --- Giriş noktası ---
def main():
    if not acquire_lock():
        sys.exit(1)

    try:
        daemon = TulparDaemon()
        daemon.run()
    except Exception as e:
        log.error("Beklenmeyen hata: %s", e)
    finally:
        release_lock()
        log.info("Tulpar daemon sonlandı.")


if __name__ == "__main__":
    main()
