#!/bin/bash
# Tulpar — Kaldırma Scripti

set -e

INSTALL_DIR="/usr/local/bin"
AUTOSTART_DIR="/etc/xdg/autostart"
LOG_DIR="$HOME/.config/tulpar"

echo "=== Tulpar Kaldırma ==="

# Çalışan daemon'u durdur
if pgrep -f "tulpar_daemon.py" > /dev/null 2>&1; then
    echo "Çalışan daemon durduruluyor..."
    pkill -f "tulpar_daemon.py" || true
fi

# Dosyaları kaldır
echo "Dosyalar kaldırılıyor..."
sudo rm -f "$INSTALL_DIR/tulpar_daemon.py"
sudo rm -f "$INSTALL_DIR/tulpar_settings.py"

# Autostart kaldır
sudo rm -f "$AUTOSTART_DIR/tulpar-daemon.desktop"

# İkon kaldır
sudo rm -f /usr/share/icons/tulpar.svg

# Masaüstü kısayolunu kaldır
DESKTOP_DIR="$HOME/Masaüstü"
if [ ! -d "$DESKTOP_DIR" ]; then
    DESKTOP_DIR="$HOME/Desktop"
fi
rm -f "$DESKTOP_DIR/tulpar-settings.desktop"

# Log dizinini kaldır
rm -rf "$LOG_DIR"

echo "Tulpar kaldırıldı."
echo "Not: /etc/tulpar/tulpar.conf dosyası korundu. Silmek için: sudo rm -rf /etc/tulpar"
