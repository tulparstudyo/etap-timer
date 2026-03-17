#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
import sys
import os
import fcntl

LOCK_DIR = os.path.join(os.path.expanduser("~"), ".local", "share", "tulpar-kilit")
LOCK_FILE = os.path.join(LOCK_DIR, "tulpar_lock.pid")

_lock_fd = None


def acquire_lock():
    """PID dosyası ile tek instance garantisi. Zaten çalışıyorsa çık."""
    global _lock_fd
    os.makedirs(LOCK_DIR, exist_ok=True)
    try:
        _lock_fd = open(LOCK_FILE, "w")
        fcntl.flock(_lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        _lock_fd.write(str(os.getpid()))
        _lock_fd.flush()
        return True
    except (IOError, OSError):
        print(f"[WARN] tulpar_lock.py zaten çalışıyor, çıkılıyor.")
        sys.exit(0)


def main():
    acquire_lock()

    from helper import get_config
    from lock_screen import LockScreen

    config = get_config()
    win = LockScreen(
        api_url=config["API_URL"],
        institution_code=config["INSTITUTION_CODE"],
        offline_secret=config["OFFLINE_SECRET"],
        institution_name=config["INSTITUTION_NAME"],
        unlock_duration=config["UNLOCK_DURATION"]
    )
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()


if __name__ == "__main__":
    main()
