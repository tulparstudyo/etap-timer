#!/bin/bash
# ============================================
# Tulpar Kilit — Otomatik Masaüstü Kurulumu
# ============================================
set -e

INSTALL_DIR="/opt/tulpar-kilit"
CURRENT_USER=$(whoami)

echo "🔒 Tulpar Kilit Kurulumu Başlıyor..."
echo ""

# --- 1. Sistem bağımlılıkları ---
echo "📦 Sistem paketleri kuruluyor..."
sudo apt-get update -qq
sudo apt-get install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0 python3-pip git

# --- 2. Kurulum dizinini oluştur (tüm kullanıcılar okuyabilir) ---
if [ -d "$INSTALL_DIR" ]; then
  echo "📁 Mevcut kurulum bulundu, güncelleniyor..."
  cd "$INSTALL_DIR"
  sudo git fetch origin
  sudo git reset --hard origin/main
else
  echo "📥 Proje indiriliyor..."
  sudo mkdir -p "$INSTALL_DIR"
  sudo git clone https://github.com/tulparstudyo/kilit.git "$INSTALL_DIR"
fi

# Tüm kullanıcıların uygulamayı çalıştırabilmesi için okuma+çalıştırma izni ver
sudo chown -R root:root "$INSTALL_DIR"
sudo chmod -R 755 "$INSTALL_DIR"
# .env dosyası hassas bilgi içerir, sadece root okuyabilsin
if [ -f "$INSTALL_DIR/desktop/.env" ]; then
  sudo chmod 644 "$INSTALL_DIR/desktop/.env"
fi

cd "$INSTALL_DIR"

# --- 3. Python bağımlılıkları ---
echo "🐍 Python bağımlılıkları kuruluyor..."
pip3 install --break-system-packages -r desktop/requirements.txt 2>/dev/null || \
pip3 install -r desktop/requirements.txt

# --- 4. .env yapılandırması ---
ENV_FILE="$INSTALL_DIR/desktop/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo ""
  echo "⚙️  Yapılandırma ayarları"
  echo "========================"

  read -p "API adresi [https://kilit.dosyamosya.com]: " API_URL < /dev/tty
  API_URL=${API_URL:-https://kilit.dosyamosya.com}

  read -p "Offline secret [tulpar_offline_secret_key]: " OFFLINE_SECRET < /dev/tty
  OFFLINE_SECRET=${OFFLINE_SECRET:-tulpar_offline_secret_key}

  read -p "Kilitsiz kalma süresi (dakika) [40]: " UNLOCK_DURATION < /dev/tty
  UNLOCK_DURATION=${UNLOCK_DURATION:-40}

  read -p "Kurum kodu (yöneticinizden alın): " INSTITUTION_CODE < /dev/tty
  read -p "Kurum adı (opsiyonel, boş bırakabilirsiniz): " INSTITUTION_NAME < /dev/tty

  sudo tee "$ENV_FILE" > /dev/null << ENVEOF
API_URL=${API_URL}
OFFLINE_SECRET=${OFFLINE_SECRET}
UNLOCK_DURATION=${UNLOCK_DURATION}
INSTITUTION_CODE=${INSTITUTION_CODE}
INSTITUTION_NAME=${INSTITUTION_NAME}
ENVEOF

  sudo chmod 644 "$ENV_FILE"
  echo "✅ Yapılandırma kaydedildi"
else
  echo "⚙️  Mevcut yapılandırma korunuyor"
fi

# --- 5. Tüm kullanıcılar için systemd servisi ---
echo "🔧 Sistem servisi oluşturuluyor..."
sudo tee /etc/systemd/system/tulpar-kilit@.service > /dev/null << 'EOF'
[Unit]
Description=Tulpar Kilit Ekran Kilidi
After=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/tulpar-kilit/desktop/tulpar_lock.py
Restart=on-failure
RestartSec=5
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/%i/.Xauthority

[Install]
WantedBy=default.target
EOF

# --- 6. Tüm kullanıcılar için autostart ---
echo "🖥️  Tüm kullanıcılar için otomatik başlatma ayarlanıyor..."
sudo tee /etc/xdg/autostart/tulpar-kilit.desktop > /dev/null << EOF
[Desktop Entry]
Type=Application
Name=Tulpar Kilit
Exec=/usr/bin/python3 ${INSTALL_DIR}/desktop/tulpar_lock.py
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Comment=Tulpar QR Kilit Sistemi
Icon=system-lock-screen
EOF

# --- 7. Masaüstü kısayolu ---
echo "🖥️  Masaüstü kısayolu oluşturuluyor..."

# Başlatıcı wrapper script (PYTHONPATH sorununu çözer)
sudo tee ${INSTALL_DIR}/tulpar-launcher.sh > /dev/null << 'WRAPPER'
#!/bin/bash
cd /opt/tulpar-kilit/desktop
exec /usr/bin/python3 tulpar_launcher.py
WRAPPER
sudo chmod +x ${INSTALL_DIR}/tulpar-launcher.sh

# Tüm kullanıcılar için masaüstü kısayolu şablonu
sudo tee /usr/share/applications/tulpar-kilit-launcher.desktop > /dev/null << EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=Tulpar Kilit
Comment=Ekranı QR ile kilitle
Exec=${INSTALL_DIR}/tulpar-launcher.sh
Icon=system-lock-screen
Terminal=false
Categories=Utility;Security;
StartupNotify=true
EOF

# Yeni oluşturulacak kullanıcılar için şablon masaüstüne kopyala
sudo mkdir -p /etc/skel/Masaüstü /etc/skel/Desktop
sudo cp /usr/share/applications/tulpar-kilit-launcher.desktop /etc/skel/Masaüstü/tulpar-kilit.desktop
sudo cp /usr/share/applications/tulpar-kilit-launcher.desktop /etc/skel/Desktop/tulpar-kilit.desktop
sudo chmod +x /etc/skel/Masaüstü/tulpar-kilit.desktop /etc/skel/Desktop/tulpar-kilit.desktop

# Mevcut tüm kullanıcıların masaüstüne kısayol kopyala
for USER_HOME in /home/*; do
  [ -d "$USER_HOME" ] || continue
  USERNAME=$(basename "$USER_HOME")
  
  SHORTCUT_PLACED=false
  
  # Önce xdg-user-dir ile kullanıcının gerçek masaüstü dizinini bul
  XDG_DESKTOP=$(sudo -u "$USERNAME" xdg-user-dir DESKTOP 2>/dev/null || echo "")
  if [ -n "$XDG_DESKTOP" ] && [ "$XDG_DESKTOP" != "$USER_HOME" ]; then
    # Dizin yoksa oluştur (kullanıcı henüz oturum açmamış olabilir)
    if [ ! -d "$XDG_DESKTOP" ]; then
      sudo mkdir -p "$XDG_DESKTOP"
      sudo chown "$USERNAME":"$USERNAME" "$XDG_DESKTOP"
    fi
    sudo cp /usr/share/applications/tulpar-kilit-launcher.desktop "$XDG_DESKTOP/tulpar-kilit.desktop"
    sudo chmod +x "$XDG_DESKTOP/tulpar-kilit.desktop"
    sudo chown "$USERNAME":"$USERNAME" "$XDG_DESKTOP/tulpar-kilit.desktop"
    sudo -u "$USERNAME" gio set "$XDG_DESKTOP/tulpar-kilit.desktop" metadata::trusted true 2>/dev/null || true
    echo "  ✅ $USERNAME → $XDG_DESKTOP/tulpar-kilit.desktop"
    SHORTCUT_PLACED=true
  fi
  
  # xdg bulamadıysa veya ek olarak bilinen dizin isimlerini de kontrol et
  if [ "$SHORTCUT_PLACED" = false ]; then
    for DIR_NAME in Masaüstü Desktop; do
      TARGET_DIR="$USER_HOME/$DIR_NAME"
      # Dizin yoksa oluştur
      if [ ! -d "$TARGET_DIR" ]; then
        sudo mkdir -p "$TARGET_DIR"
        sudo chown "$USERNAME":"$USERNAME" "$TARGET_DIR"
      fi
      sudo cp /usr/share/applications/tulpar-kilit-launcher.desktop "$TARGET_DIR/tulpar-kilit.desktop"
      sudo chmod +x "$TARGET_DIR/tulpar-kilit.desktop"
      sudo chown "$USERNAME":"$USERNAME" "$TARGET_DIR/tulpar-kilit.desktop"
      sudo -u "$USERNAME" gio set "$TARGET_DIR/tulpar-kilit.desktop" metadata::trusted true 2>/dev/null || true
      echo "  ✅ $USERNAME → $TARGET_DIR/tulpar-kilit.desktop"
      SHORTCUT_PLACED=true
    done
  fi
  
  if [ "$SHORTCUT_PLACED" = false ]; then
    echo "  ⚠️  $USERNAME için masaüstü dizini bulunamadı/oluşturulamadı"
  fi
done
echo "✅ Masaüstü kısayolu tüm kullanıcılara dağıtıldı"

# --- 8. Bitti ---
echo ""
echo "============================================"
echo "✅ Kurulum tamamlandı!"
echo ""
echo "📍 Kurulum dizini: $INSTALL_DIR (tüm kullanıcılar erişebilir)"
echo "🖥️  Uygulama tüm kullanıcılar için oturum açılışında başlayacak"
echo ""
echo "🚀 Elle başlatmak için:"
echo "   python3 $INSTALL_DIR/desktop/tulpar_lock.py"
echo "============================================"
echo ""

read -p "Uygulamayı şimdi başlatmak ister misiniz? (e/h): " START < /dev/tty
if [ "$START" = "e" ] || [ "$START" = "E" ]; then
  python3 "$INSTALL_DIR/desktop/tulpar_lock.py"
fi
