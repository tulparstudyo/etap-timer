---
inclusion: always
---

# Tulpar - Teknoloji ve Geliştirme Kuralları

## Platform

- Hedef işletim sistemi: Pardus Linux (Debian tabanlı)
- Masaüstü ortamı: XFCE (Pardus varsayılanı)

## Teknoloji Seçimleri

- Dil: Python 3 (ana mantık, daemon ve ayarlar arayüzü)
- GUI framework: PyGObject (GTK 3, Zenity yerine native GTK pencereleri)
- Zamanlayıcı: threading.Timer veya GLib.timeout_add (daemon içi zamanlama)
- Idle algılama: xprintidle (subprocess ile çağrılır)
- Oturum yönetimi: subprocess ile xfce4-session-logout, loginctl
- Kapatma: subprocess ile systemctl poweroff
- Konfigürasyon parse: configparser veya düz key=value okuma

## Konfigürasyon

- Ayarlar dosyası: `/etc/tulpar/tulpar.conf`
- Dosya sahibi: root:root, izinler: 644 (tüm kullanıcılar okuyabilir, değiştirmek için sudo gerekir)
- Format: key=value çiftleri (configparser INI formatı veya düz satır okuma)
- Varsayılan değerler kodda tanımlı olmalı, conf dosyası yoksa kurulum sırasında oluşturulmalı
- Ayarlar penceresi yazma işlemlerini `pkexec` veya `sudo` ile yapmalı

## Kodlama Kuralları

- Tüm Python dosyaları `#!/usr/bin/env python3` shebang ile başlamalı
- Kodlama satırı: `# -*- coding: utf-8 -*-`
- Değişken ve fonksiyon isimleri snake_case
- Sınıf isimleri PascalCase
- Sabitler UPPER_SNAKE_CASE
- Hata durumları loglanmalı: `~/.config/tulpar/tulpar.log` (logging modülü ile)
- Single instance kontrolü: lock dosyası (`fcntl.flock`) ile sağlanmalı
- Oturum kapanışında temiz çıkış: SIGTERM ve SIGHUP sinyalleri yakalanmalı, kaynaklar serbest bırakılmalı
- Masaüstü sayacı: Gtk.Window ile always-on-top, dekorasyonsuz, küçük overlay pencere olarak gösterilmeli
- PEP 8 stil kurallarına uyulmalı
- Type hint kullanımı teşvik edilir

## Kurulum

- Kurulum scripti `install.sh` ile yapılmalı (bash)
- wget ile uzaktan indirme desteklenmeli
- Python bağımlılıkları: PyGObject (sistem paketi: `gir1.2-gtk-3.0`, `python3-gi`)
- Autostart için `~/.config/autostart/` altına `.desktop` dosyası oluşturulmalı
- Masaüstü kısayolu için `~/Masaüstü/` veya `~/Desktop/` altına `.desktop` dosyası oluşturulmalı
