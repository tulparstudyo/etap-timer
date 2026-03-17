#!/bin/bash
# Tulpar - Kurulum Scripti

set -e

INSTALL_DIR="/opt/tulpar"
CONFIG_DIR="$HOME/.config/tulpar"
AUTOSTART_DIR="$HOME/.config/autostart"

# Masaüstü dizinini belirle
if [ -d "$HOME/Masaüstü" ]; then
    DESKTOP_DIR="$HOME/Masaüstü"
elif [ -d "$HOME/Desktop" ]; then
    DESKTOP_DIR="$HOME/Desktop"
else
    DESKTOP_DIR="$HOME/Desktop"
    mkdir -p "$DESKTOP_DIR"
fi

echo "=== Tulpar Kurulumu ==="

# Gerekli paketleri kontrol et
missing_packages=""
if ! command -v zenity &>/dev/null; then
    missing_packages="$missing_packages zenity"
fi
if ! command -v xprintidle &>/dev/null; then
    missing_packages="$missing_packages xprintidle"
fi

if [ -n "$missing_packages" ]; then
    echo "Eksik paketler kuruluyor:$missing_packages"
    sudo apt-get update -qq
    sudo apt-get install -y $missing_packages
fi

# Kurulum dizinini oluştur
echo "Dosyalar kopyalanıyor..."
sudo mkdir -p "$INSTALL_DIR"
sudo cp tulpar-daemon.sh "$INSTALL_DIR/"
sudo cp tulpar-settings.sh "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/tulpar-daemon.sh"
sudo chmod +x "$INSTALL_DIR/tulpar-settings.sh"

# Config dizinini oluştur
mkdir -p "$CONFIG_DIR"

# Varsayılan config dosyası oluştur (yoksa)
if [ ! -f "$CONFIG_DIR/tulpar.conf" ]; then
    cat > "$CONFIG_DIR/tulpar.conf" << EOF
SESSION_DURATION=60
IDLE_DURATION=10
TURNOFF_TIME=23:00
EOF
    echo "Varsayılan ayarlar oluşturuldu."
fi

# Kurulumu yapan kullanıcıyı kaydet
echo "$USER" > "$CONFIG_DIR/.install_user"

# Autostart dosyasını kopyala
mkdir -p "$AUTOSTART_DIR"
cp tulpar-daemon.desktop "$AUTOSTART_DIR/"

# Masaüstü kısayolunu oluştur
cp tulpar-settings.desktop "$DESKTOP_DIR/"
chmod +x "$DESKTOP_DIR/tulpar-settings.desktop"

echo ""
echo "=== Tulpar başarıyla kuruldu ==="
echo "  Ayarlar kısayolu: $DESKTOP_DIR/tulpar-settings.desktop"
echo "  Daemon bir sonraki oturum açılışında otomatik başlayacak."
echo "  Hemen başlatmak için: bash $INSTALL_DIR/tulpar-daemon.sh &"
