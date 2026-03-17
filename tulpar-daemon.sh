#!/bin/bash
# Tulpar - Ana Daemon
# Oturum açılınca başlar, zamanlayıcıları yönetir

CONFIG_DIR="$HOME/.config/tulpar"
CONFIG_FILE="$CONFIG_DIR/tulpar.conf"
GLOBAL_CONFIG_FILE="/etc/tulpar/tulpar.conf"
LOG_FILE="$CONFIG_DIR/tulpar.log"
LOCK_FILE="/tmp/tulpar-daemon-$USER.lock"
SESSION_START_FILE="$CONFIG_DIR/.session_start"

# Varsayılan değerler
DEFAULT_SESSION_DURATION=60
DEFAULT_IDLE_DURATION=10
DEFAULT_TURNOFF_TIME="23:00"

CHECK_INTERVAL=30  # Kontrol aralığı (saniye)
REMAINING_FILE="$CONFIG_DIR/.remaining"

log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

write_remaining() {
    local now=$1
    local remaining_session=$(( (SESSION_DURATION * 60) - (now - session_start) ))

    local remaining_turnoff=999999
    local turnoff_sec
    turnoff_sec=$(date -d "$TURNOFF_TIME" +%s 2>/dev/null)
    if [ -n "$turnoff_sec" ]; then
        remaining_turnoff=$(( turnoff_sec - now ))
        [ "$remaining_turnoff" -lt 0 ] && remaining_turnoff=0
    fi

    local min_remaining=$remaining_session
    local reason="oturum"
    if [ "$remaining_turnoff" -lt "$min_remaining" ]; then
        min_remaining=$remaining_turnoff
        reason="kapanma"
    fi

    [ "$min_remaining" -lt 0 ] && min_remaining=0

    local hours=$(( min_remaining / 3600 ))
    local mins=$(( (min_remaining % 3600) / 60 ))

    local text
    if [ "$hours" -gt 0 ]; then
        text="⏱ ${hours}s ${mins}dk ($reason)"
    else
        text="⏱ ${mins} dk ($reason)"
    fi

    echo "$text" > "$REMAINING_FILE"
}

# --- Single instance kontrolü ---

if [ -f "$LOCK_FILE" ]; then
    existing_pid=$(cat "$LOCK_FILE")
    if kill -0 "$existing_pid" 2>/dev/null; then
        log_msg "Daemon zaten çalışıyor (PID: $existing_pid). Çıkılıyor."
        exit 0
    else
        log_msg "Eski lock dosyası temizleniyor."
        rm -f "$LOCK_FILE"
    fi
fi

OVERLAY_LOCK="/tmp/tulpar-overlay-$USER.lock"

stop_overlay() {
    if [ -f "$OVERLAY_LOCK" ]; then
        local overlay_pid
        overlay_pid=$(cat "$OVERLAY_LOCK")
        if kill -0 "$overlay_pid" 2>/dev/null; then
            kill "$overlay_pid" 2>/dev/null
        fi
    fi
}

echo $$ > "$LOCK_FILE"
trap 'stop_overlay; rm -f "$LOCK_FILE" "$REMAINING_FILE"; exit 0' EXIT INT TERM

# Config dizinini oluştur
mkdir -p "$CONFIG_DIR"

load_config() {
    # Önce sistem geneli config'i oku (kurulumu yapan kullanıcının ayarları)
    if [ -f "$GLOBAL_CONFIG_FILE" ]; then
        source "$GLOBAL_CONFIG_FILE"
    fi
    # Kullanıcıya özel config varsa üzerine yaz
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
    SESSION_DURATION="${SESSION_DURATION:-$DEFAULT_SESSION_DURATION}"
    IDLE_DURATION="${IDLE_DURATION:-$DEFAULT_IDLE_DURATION}"
    TURNOFF_TIME="${TURNOFF_TIME:-$DEFAULT_TURNOFF_TIME}"
}

# İlk yükleme
load_config
log_msg "Tulpar daemon başlatıldı. SESSION=$SESSION_DURATION dk, IDLE=$IDLE_DURATION dk, TURNOFF=$TURNOFF_TIME"

# Oturum başlangıç zamanı
session_start=$(date +%s)
echo "$session_start" > "$SESSION_START_FILE"

# İlk kalan süreyi hemen yaz (overlay "bekleniyor" göstermesin)
write_remaining "$(date +%s)"

# Masaüstü overlay'ini başlat
OVERLAY_SCRIPT="/opt/tulpar/tulpar-overlay.sh"
if [ -x "$OVERLAY_SCRIPT" ]; then
    bash "$OVERLAY_SCRIPT" &
    log_msg "Masaüstü sayacı başlatıldı."
fi

# --- Ana döngü ---

while true; do
    load_config
    now=$(date +%s)

    # 1. SESSION_DURATION kontrolü
    session_elapsed=$(( (now - session_start) / 60 ))
    if [ "$session_elapsed" -ge "$SESSION_DURATION" ]; then
        log_msg "Oturum süresi doldu ($SESSION_DURATION dk). Oturum kapatılıyor."
        xfce4-session-logout --logout --fast 2>/dev/null || loginctl terminate-user "$USER" 2>/dev/null
        exit 0
    fi

    # 2. IDLE_DURATION kontrolü (xprintidle milisaniye döner)
    if command -v xprintidle &>/dev/null; then
        idle_ms=$(xprintidle 2>/dev/null || echo "0")
        idle_min=$(( idle_ms / 60000 ))
        if [ "$idle_min" -ge "$IDLE_DURATION" ]; then
            log_msg "Boşta kalma süresi doldu ($IDLE_DURATION dk). Oturum kapatılıyor."
            xfce4-session-logout --logout --fast 2>/dev/null || loginctl terminate-user "$USER" 2>/dev/null
            exit 0
        fi
    fi

    # 3. TURNOFF_TIME kontrolü
    current_time=$(date +%H:%M)
    turnoff_seconds=$(date -d "$TURNOFF_TIME" +%s 2>/dev/null)
    current_seconds=$(date -d "$current_time" +%s 2>/dev/null)
    if [ -n "$turnoff_seconds" ] && [ -n "$current_seconds" ] && [ "$current_seconds" -ge "$turnoff_seconds" ]; then
        log_msg "Kapanma saati geçti ($TURNOFF_TIME). Bilgisayar kapatılıyor."
        systemctl poweroff
        exit 0
    fi

    # 4. Kalan süreyi dosyaya yaz (overlay için)
    write_remaining "$now"

    sleep "$CHECK_INTERVAL"
done
