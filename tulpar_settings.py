#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Tulpar Ayarlar Penceresi — GTK 3 ile konfigürasyon düzenleme."""

import os
import subprocess
import sys
import tempfile

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

CONFIG_PATH = "/etc/tulpar/tulpar.conf"

DEFAULTS = {
    "SESSION_DURATION": "0",
    "IDLE_DURATION": "0",
    "TURNOFF_TIME": "",
}


def read_config() -> dict:
    """Mevcut konfigürasyonu okur."""
    config = dict(DEFAULTS)
    if not os.path.isfile(CONFIG_PATH):
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
                    if key in config:
                        config[key] = value
    except Exception:
        pass
    return config


def write_config(config: dict) -> bool:
    """Konfigürasyonu pkexec ile yazar."""
    content = "# Tulpar konfigürasyon dosyası\n"
    for key, value in config.items():
        content += f'{key}={value}\n'

    try:
        tmp = tempfile.NamedTemporaryFile(mode="w", suffix=".conf", delete=False)
        tmp.write(content)
        tmp.close()

        # pkexec ile /etc/tulpar/tulpar.conf'a kopyala
        result = subprocess.run(
            ["pkexec", "bash", "-c",
             f"mkdir -p /etc/tulpar && cp {tmp.name} {CONFIG_PATH} && "
             f"chmod 644 {CONFIG_PATH} && chown root:root {CONFIG_PATH}"],
            capture_output=True, text=True
        )
        os.unlink(tmp.name)
        return result.returncode == 0
    except Exception:
        return False


class SettingsWindow(Gtk.Window):
    """Tulpar ayarlar penceresi."""

    def __init__(self):
        super().__init__(title="Tulpar Ayarları")
        self.set_default_size(360, 220)
        self.set_border_width(16)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_resizable(False)

        config = read_config()

        grid = Gtk.Grid(column_spacing=12, row_spacing=10)
        self.add(grid)

        # SESSION_DURATION
        lbl_session = Gtk.Label(label="Oturum Süresi (dakika):", xalign=0)
        self.spin_session = Gtk.SpinButton.new_with_range(0, 1440, 1)
        self.spin_session.set_value(int(config.get("SESSION_DURATION", 0)))
        grid.attach(lbl_session, 0, 0, 1, 1)
        grid.attach(self.spin_session, 1, 0, 1, 1)

        # IDLE_DURATION
        lbl_idle = Gtk.Label(label="Boşta Kalma Süresi (dakika):", xalign=0)
        self.spin_idle = Gtk.SpinButton.new_with_range(0, 1440, 1)
        self.spin_idle.set_value(int(config.get("IDLE_DURATION", 0)))
        grid.attach(lbl_idle, 0, 1, 1, 1)
        grid.attach(self.spin_idle, 1, 1, 1, 1)

        # TURNOFF_TIME
        lbl_turnoff = Gtk.Label(label="Kapanma Saati (SS:DD):", xalign=0)
        self.entry_turnoff = Gtk.Entry()
        self.entry_turnoff.set_text(config.get("TURNOFF_TIME", ""))
        self.entry_turnoff.set_placeholder_text("ör: 22:00")
        self.entry_turnoff.set_max_length(5)
        grid.attach(lbl_turnoff, 0, 2, 1, 1)
        grid.attach(self.entry_turnoff, 1, 2, 1, 1)

        # Kaydet butonu
        btn_save = Gtk.Button(label="Kaydet")
        btn_save.connect("clicked", self._on_save)
        grid.attach(btn_save, 0, 3, 2, 1)

        self.connect("destroy", Gtk.main_quit)
        self.show_all()

    def _on_save(self, button):
        turnoff = self.entry_turnoff.get_text().strip()

        # Basit HH:MM doğrulama
        if turnoff:
            parts = turnoff.split(":")
            if len(parts) != 2 or not parts[0].isdigit() or not parts[1].isdigit():
                self._show_error("Kapanma saati SS:DD formatında olmalıdır.")
                return
            h, m = int(parts[0]), int(parts[1])
            if h > 23 or m > 59:
                self._show_error("Geçersiz saat değeri.")
                return

        config = {
            "SESSION_DURATION": str(int(self.spin_session.get_value())),
            "IDLE_DURATION": str(int(self.spin_idle.get_value())),
            "TURNOFF_TIME": turnoff,
        }

        if write_config(config):
            dialog = Gtk.MessageDialog(
                transient_for=self,
                message_type=Gtk.MessageType.INFO,
                buttons=Gtk.ButtonsType.OK,
                text="Ayarlar kaydedildi.",
            )
            dialog.format_secondary_text(
                "Değişikliklerin etkili olması için daemon'un yeniden başlatılması gerekir."
            )
            dialog.run()
            dialog.destroy()
        else:
            self._show_error("Ayarlar kaydedilemedi. Yetki hatası olabilir.")

    def _show_error(self, message: str):
        dialog = Gtk.MessageDialog(
            transient_for=self,
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.OK,
            text=message,
        )
        dialog.run()
        dialog.destroy()


def main():
    SettingsWindow()
    Gtk.main()


if __name__ == "__main__":
    main()
