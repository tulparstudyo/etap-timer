#!/bin/bash
# Tulpar - Masaüstü Sayaç Overlay
# Kalan süreyi masaüstünde gösterir
# Pencere fare ile taşınabilir, konum hatırlanır
# yad penceresi periyodik olarak yeniden oluşturularak güncellenir

CONFIG_DIR="$HOME/.config/tulpar"
REMAINING_FILE="$CONFIG_DIR/.remaining"
OVERLAY_LOCK="/tmp/tulpar-overlay-$USER.lock"
DAEMON_LOCK="/tmp/tulpar-daemon-$USER.lock"
POSITION_FILE="$CONFIG_DIR/.overlay_position"
UPDATE_INTERVAL=5

# Single instance kontrolü
if [ -f "$OVERLAY_LOCK" ]; then
    existing_pid=$(cat "$OVERLAY_LOCK")
    if kill -0 "$existing_pid" 2>/dev/null; then
        exit 0
    fi
    rm -f "$OVERLAY_LOCK"
fi

echo $$ > "$OVERLAY_LOCK"

# yad yoksa çık
if ! command -v yad &>/dev/null; then
    rm -f "$OVERLAY_LOCK"
    exit 1
fi

YAD_PID=""
YAD_WID=""

cleanup() {
    save_position
    [ -n "$YAD_PID" ] && kill "$YAD_PID" 2>/dev/null
    rm -f "$OVERLAY_LOCK"
    exit 0
}
trap cleanup EXIT INT TERM

# xdotool ile mevcut pencere konumunu kaydet
save_position() {
    if command -v xdotool &>/dev/null && [ -n "$YAD_WID" ] && [ -n "$YAD_PID" ] && kill -0 "$YAD_PID" 2>/dev/null; then
        local info
        info=$(xdotool getwindowgeometry "$YAD_WID" 2>/dev/null) || return
        local x y
        x=$(echo "$info" | sed -n 's/.*Position: \([0-9]*\),.*/\1/p')
        y=$(echo "$info" | sed -n 's/.*Position: [0-9]*,\([0-9]*\).*/\1/p')
        if [ -n "$x" ] && [ -n "$y" ]; then
            echo "${x},${y}" > "$POSITION_FILE"
        fi
    fi
}

# Kaydedilmiş konumu yad geometry formatında döndür
get_geometry() {
    if [ -f "$POSITION_FILE" ]; then
        local saved x y
        saved=$(cat "$POSITION_FILE" 2>/dev/null)
        x="${saved%%,*}"
        y="${saved##*,}"
        if [ -n "$x" ] && [ -n "$y" ] && [ "$x" -ge 0 ] 2>/dev/null && [ "$y" -ge 0 ] 2>/dev/null; then
            echo "+${x}+${y}"
            return
        fi
    fi
    # Varsayılan konum: sağ alt köşe
    echo "-20-60"
}

# yad penceresini başlat
start_yad() {
    local text="$1"
    local geometry
    geometry=$(get_geometry)

    yad --text="$text" \
        --no-buttons \
        --undecorated \
        --skip-taskbar \
        --on-top \
        --sticky \
        --close-on-unfocus=false \
        --no-focus \
        --geometry="$geometry" \
        --borders=8 \
        --text-align=center \
        --fore="#FFFFFF" \
        --back="#222222" \
        --fontname="Sans Bold 13" \
        --timeout="$((UPDATE_INTERVAL + 2))" \
        --timeout-indicator=none &
    YAD_PID=$!

    # Pencere ID'sini yakala
    YAD_WID=""
    if command -v xdotool &>/dev/null; then
        sleep 0.3
        YAD_WID=$(xdotool search --pid "$YAD_PID" 2>/dev/null | head -1)
    fi
}

# Gösterilecek metni oku
get_display_text() {
    if [ -f "$REMAINING_FILE" ]; then
        cat "$REMAINING_FILE" 2>/dev/null
    else
        echo "Tulpar bekleniyor..."
    fi
}

# İlk pencereyi aç
current_text=$(get_display_text)
start_yad "$current_text"

# --- Ana döngü ---
while true; do
    sleep "$UPDATE_INTERVAL"

    # Daemon çalışmıyorsa overlay'i kapat
    if [ -f "$DAEMON_LOCK" ]; then
        daemon_pid=$(cat "$DAEMON_LOCK")
        if ! kill -0 "$daemon_pid" 2>/dev/null; then
            break
        fi
    else
        break
    fi

    # Yeni metni oku
    new_text=$(get_display_text)

    # Metin değiştiyse veya yad kapandıysa pencereyi yeniden oluştur
    if [ "$new_text" != "$current_text" ] || ! kill -0 "$YAD_PID" 2>/dev/null; then
        save_position
        # Eski pencereyi kapat
        if kill -0 "$YAD_PID" 2>/dev/null; then
            kill "$YAD_PID" 2>/dev/null
            wait "$YAD_PID" 2>/dev/null
        fi
        current_text="$new_text"
        start_yad "$current_text"
    fi
done
