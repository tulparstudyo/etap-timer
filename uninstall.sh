#!/bin/bash
# Tulpar - Kaldırma Scripti

INSTALL_DIR="/opt/tulpar"
CONFIG_DIR="$HOME/.config/tulpar"
AUTOSTART_DIR="$HOME/.config/autostart"

# Masaüstü dizinini belirle
if [ -d "$HOME/Masaüstü" ]; then
    DESKTOP_DIR="$HOME/Masaüstü"
else
    DESKTOP_DIR="$HOME/Desktop"
fi

echo "=== Tulpar Kaldırılıyor ==="

# Çalışan daemon'u durdur
if [ -f "/tmp/tulpar-daemon-$USER.lock" ]; then
    pid=$(cat "/tmp/tulpar-daemon-$USER.lock")
    if kill -0 "$pid" 2>/dev/null; then
        echo "Daemon durduruluyor (PID: $pid)..."
        kill "$pid" 2>/dev/null
    fi
    rm -f "/tmp/tulpar-daemon-$USER.lock"
fi

# Kurulum dosyalarını kaldır
if [ -d "$INSTALL_DIR" ]; then
    echo "Kurulum dosyaları kaldırılıyor..."
    sudo rm -rf "$INSTALL_DIR"
fi

# Autostart dosyasını kaldır
rm -f "$AUTOSTART_DIR/tulpar-daemon.desktop"

# Masaüstü kısayolunu kaldır
rm -f "$DESKTOP_DIR/tulpar-settings.desktop"

# Kullanıcıya config dosyasını sorma
echo ""
echo "Kullanıcı ayarları ($CONFIG_DIR) korundu."
echo "Tamamen silmek için: rm -rf $CONFIG_DIR"
echo ""
echo "=== Tulpar başarıyla kaldırıldı ==="
