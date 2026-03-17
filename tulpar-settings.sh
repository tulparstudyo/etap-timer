#!/bin/bash
# Tulpar - Ayarlar Penceresi
# Zenity ile SESSION_DURATION, IDLE_DURATION ve TURNOFF_TIME ayarlarını yönetir

CONFIG_DIR="$HOME/.config/tulpar"
CONFIG_FILE="$CONFIG_DIR/tulpar.conf"
LOG_FILE="$CONFIG_DIR/tulpar.log"

# Varsayılan değerler
DEFAULT_SESSION_DURATION=60
DEFAULT_IDLE_DURATION=10
DEFAULT_TURNOFF_TIME="23:00"

# Kurulumu yapan kullanıcıyı kontrol et
INSTALL_USER_FILE="$CONFIG_DIR/.install_user"
if [ -f "$INSTALL_USER_FILE" ]; then
    install_user=$(cat "$INSTALL_USER_FILE")
    if [ "$USER" != "$install_user" ]; then
        zenity --error --title="Tulpar" --text="Ayarları yalnızca kurulumu yapan kullanıcı ($install_user) değiştirebilir." 2>/dev/null
        exit 1
    fi
fi

# Config dizinini oluştur
mkdir -p "$CONFIG_DIR"

# Mevcut ayarları oku veya varsayılanları kullan
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi
SESSION_DURATION="${SESSION_DURATION:-$DEFAULT_SESSION_DURATION}"
IDLE_DURATION="${IDLE_DURATION:-$DEFAULT_IDLE_DURATION}"
TURNOFF_TIME="${TURNOFF_TIME:-$DEFAULT_TURNOFF_TIME}"

# Zenity form ile ayarları göster
result=$(zenity --forms --title="Tulpar Ayarları" \
    --text="Oturum ve kapatma ayarlarını düzenleyin" \
    --add-entry="Oturum Süresi (dakika): [$SESSION_DURATION]" \
    --add-entry="Boşta Kalma Süresi (dakika): [$IDLE_DURATION]" \
    --add-entry="Otomatik Kapanma Saati (HH:MM): [$TURNOFF_TIME]" \
    --separator="|" 2>/dev/null)

# İptal edildiyse çık
if [ $? -ne 0 ]; then
    exit 0
fi

# Sonuçları ayrıştır
IFS='|' read -r new_session new_idle new_turnoff <<< "$result"

# Boş bırakılanlar için mevcut değerleri koru
new_session="${new_session:-$SESSION_DURATION}"
new_idle="${new_idle:-$IDLE_DURATION}"
new_turnoff="${new_turnoff:-$TURNOFF_TIME}"

# Doğrulama: sayısal değerler
if ! [[ "$new_session" =~ ^[0-9]+$ ]] || [ "$new_session" -lt 1 ]; then
    zenity --error --title="Tulpar" --text="Oturum süresi geçerli bir pozitif sayı olmalıdır." 2>/dev/null
    exit 1
fi

if ! [[ "$new_idle" =~ ^[0-9]+$ ]] || [ "$new_idle" -lt 1 ]; then
    zenity --error --title="Tulpar" --text="Boşta kalma süresi geçerli bir pozitif sayı olmalıdır." 2>/dev/null
    exit 1
fi

# Doğrulama: saat formatı
if ! [[ "$new_turnoff" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
    zenity --error --title="Tulpar" --text="Kapanma saati HH:MM formatında olmalıdır (ör: 23:00)." 2>/dev/null
    exit 1
fi

# Ayarları kaydet
cat > "$CONFIG_FILE" << EOF
SESSION_DURATION=$new_session
IDLE_DURATION=$new_idle
TURNOFF_TIME=$new_turnoff
EOF

echo "$(date '+%Y-%m-%d %H:%M:%S') - Ayarlar güncellendi: SESSION=$new_session IDLE=$new_idle TURNOFF=$new_turnoff" >> "$LOG_FILE"

zenity --info --title="Tulpar" --text="Ayarlar başarıyla kaydedildi." 2>/dev/null
