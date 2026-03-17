#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from helper import get_config
from lock_screen import LockScreen


def main():
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
