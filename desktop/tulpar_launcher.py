#!/usr/bin/env python3
"""Tulpar Kilit — Masaüstü Başlatıcı Penceresi"""
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk
import subprocess
import os
import sys


class LauncherWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="Tulpar Kilit")
        self.set_default_size(320, 180)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_resizable(False)
        self.set_border_width(24)

        # CSS
        css = b"""
        window { background-color: #2c3e50; }
        label  { color: white; }
        button.lock-btn {
            background: #e74c3c;
            color: white;
            font-size: 16px;
            padding: 12px 24px;
            border-radius: 8px;
            border: none;
        }
        button.lock-btn:hover { background: #c0392b; }
        button.cancel-btn {
            background: #7f8c8d;
            color: white;
            font-size: 14px;
            padding: 8px 20px;
            border-radius: 8px;
            border: none;
        }
        button.cancel-btn:hover { background: #95a5a6; }
        """
        provider = Gtk.CssProvider()
        provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16)
        box.set_halign(Gtk.Align.CENTER)
        box.set_valign(Gtk.Align.CENTER)

        title = Gtk.Label()
        title.set_markup('<span size="x-large" weight="bold">🔒 Tulpar Kilit</span>')
        box.pack_start(title, False, False, 0)

        # Ekranı Kilitle düğmesi
        lock_btn = Gtk.Button(label="Ekranı Kilitle")
        lock_btn.get_style_context().add_class("lock-btn")
        lock_btn.connect("clicked", self._on_lock)
        box.pack_start(lock_btn, False, False, 0)

        # Vazgeç düğmesi
        cancel_btn = Gtk.Button(label="Vazgeç")
        cancel_btn.get_style_context().add_class("cancel-btn")
        cancel_btn.connect("clicked", self._on_cancel)
        box.pack_start(cancel_btn, False, False, 0)

        self.add(box)

    def _on_lock(self, _btn):
        """Kilit ekranını başlat ve bu pencereyi kapat."""
        script_dir = os.path.dirname(os.path.abspath(__file__))
        lock_script = os.path.join(script_dir, "tulpar_lock.py")
        subprocess.Popen([sys.executable, lock_script])
        self.close()

    def _on_cancel(self, _btn):
        self.close()


def main():
    win = LauncherWindow()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()


if __name__ == "__main__":
    main()
