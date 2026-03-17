#!/bin/bash
# Tulpar - Kurulum Scripti (v2)

set -e

REPO_BASE="https://raw.githubusercontent.com/tulparstudyo/etap-timer/main"
INSTALL_DIR="/opt/tulpar"
CONFIG_DIR="$HOME/.config/tulpar"
TMP_DIR=$(mktemp -d)

# Temizlik fonksiyonu
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

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
if ! command -v yad &>/dev/null; then
    missing_packages="$missing_packages yad"
fi

if [ -n "$missing_packages" ]; then
    echo "Eksik paketler kuruluyor:$missing_packages"
    sudo apt-get update -qq
    sudo apt-get install -y $missing_packages
fi

# Dosyaları GitHub'dan indir
echo "Dosyalar indiriliyor..."
wget -q "$REPO_BASE/tulpar-daemon.sh" -O "$TMP_DIR/tulpar-daemon.sh"
wget -q "$REPO_BASE/tulpar-settings.sh" -O "$TMP_DIR/tulpar-settings.sh"
wget -q "$REPO_BASE/tulpar-daemon.desktop" -O "$TMP_DIR/tulpar-daemon.desktop"
wget -q "$REPO_BASE/tulpar-settings.desktop" -O "$TMP_DIR/tulpar-settings.desktop"
wget -q "$REPO_BASE/tulpar-overlay.sh" -O "$TMP_DIR/tulpar-overlay.sh"
wget -q "$REPO_BASE/uninstall.sh" -O "$TMP_DIR/uninstall.sh"

# Kurulum dizinine kopyala
echo "Dosyalar kuruluyor..."
sudo mkdir -p "$INSTALL_DIR"
sudo cp "$TMP_DIR/tulpar-daemon.sh" "$INSTALL_DIR/"
sudo cp "$TMP_DIR/tulpar-settings.sh" "$INSTALL_DIR/"
sudo cp "$TMP_DIR/tulpar-overlay.sh" "$INSTALL_DIR/"
sudo cp "$TMP_DIR/uninstall.sh" "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/tulpar-daemon.sh"
sudo chmod +x "$INSTALL_DIR/tulpar-settings.sh"
sudo chmod +x "$INSTALL_DIR/tulpar-overlay.sh"
sudo chmod +x "$INSTALL_DIR/uninstall.sh"

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

# Autostart dosyasını tüm kullanıcılar için /etc/xdg/autostart/ altına kopyala
echo "Autostart ayarlanıyor (tüm kullanıcılar)..."
sudo cp "$TMP_DIR/tulpar-daemon.desktop" /etc/xdg/autostart/tulpar-daemon.desktop

# Masaüstü kısayolunu oluştur
cp "$TMP_DIR/tulpar-settings.desktop" "$DESKTOP_DIR/"
chmod +x "$DESKTOP_DIR/tulpar-settings.desktop"

echo ""
echo "=== Tulpar başarıyla kuruldu ==="
echo "  Ayarlar kısayolu: $DESKTOP_DIR/tulpar-settings.desktop"
echo "  Daemon bir sonraki oturum açılışında otomatik başlayacak."
echo "  Hemen başlatmak için: bash $INSTALL_DIR/tulpar-daemon.sh &"
