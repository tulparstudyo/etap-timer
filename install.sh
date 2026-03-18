#!/bin/bash
# Tulpar — Kurulum Scripti

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/tulpar"
CONFIG_FILE="$CONFIG_DIR/tulpar.conf"
AUTOSTART_DIR="/etc/xdg/autostart"
LOG_DIR="$HOME/.config/tulpar"

# Renk tanımları
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "=== Tulpar Kurulum ==="

# Bağımlılık kontrolü
echo "Bağımlılıklar kontrol ediliyor..."
MISSING=""
for pkg in python3 xprintidle; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        MISSING="$MISSING $pkg"
    fi
done

# python3-gi kontrolü
if ! python3 -c "import gi" >/dev/null 2>&1; then
    MISSING="$MISSING python3-gi"
fi

if [ -n "$MISSING" ]; then
    echo -e "${RED}Eksik paketler:${NC}$MISSING"
    echo "Kurmak için: sudo apt install$MISSING"
    exit 1
fi

echo -e "${GREEN}Bağımlılıklar tamam.${NC}"

# Python dosyalarını kopyala
echo "Dosyalar kopyalanıyor..."
sudo cp "$SCRIPT_DIR/tulpar_daemon.py" "$INSTALL_DIR/tulpar_daemon.py"
sudo cp "$SCRIPT_DIR/tulpar_settings.py" "$INSTALL_DIR/tulpar_settings.py"
sudo chmod 755 "$INSTALL_DIR/tulpar_daemon.py"
sudo chmod 755 "$INSTALL_DIR/tulpar_settings.py"

# Konfigürasyon dosyası oluştur (yoksa)
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Konfigürasyon dosyası oluşturuluyor..."
    sudo mkdir -p "$CONFIG_DIR"
    sudo tee "$CONFIG_FILE" > /dev/null <<EOF
# Tulpar konfigürasyon dosyası
SESSION_DURATION=0
IDLE_DURATION=0
TURNOFF_TIME=
EOF
    sudo chmod 644 "$CONFIG_FILE"
    sudo chown root:root "$CONFIG_FILE"
fi

# Autostart (sistem geneli — tüm kullanıcılar için)
sudo cp "$SCRIPT_DIR/tulpar-daemon.desktop" "$AUTOSTART_DIR/tulpar-daemon.desktop"

# Masaüstü kısayolu
DESKTOP_DIR="$HOME/Masaüstü"
if [ ! -d "$DESKTOP_DIR" ]; then
    DESKTOP_DIR="$HOME/Desktop"
fi
if [ -d "$DESKTOP_DIR" ]; then
    cp "$SCRIPT_DIR/tulpar-settings.desktop" "$DESKTOP_DIR/tulpar-settings.desktop"
    chmod +x "$DESKTOP_DIR/tulpar-settings.desktop"
fi

echo -e "${GREEN}Tulpar başarıyla kuruldu.${NC}"
echo "Daemon bir sonraki oturum açılışında otomatik başlayacaktır."
echo "Şimdi başlatmak için: $INSTALL_DIR/tulpar_daemon.py &"

# Kurulum dosyalarını otomatik temizle
cd /
rm -rf "$SCRIPT_DIR"
