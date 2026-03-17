#!/bin/bash
# Tulpar - Masaüstü Sayaç Overlay
# Kalan süreyi masaüstünde gösterir
# Pencere fare ile taşınabilir (Alt+Sol Tık veya sürükle), konum hatırlanır
# yad --multi-progress + named pipe ile pencere kapanmadan güncellenir

CONFIG_DIR="$HOME/.config/tulpar"
REMAINING_FILE="$CONFIG_DIR/.remaining"
OVERLAY_LOCK="/tmp/tulpar-overlay-$USER.lock"
DAEMON_LOCK="/tmp/tulpar-daemon-$USER.lock"
POSITION_FILE="$CONFIG_DIR/.overlay_position"
FIFO_FILE="/tmp/tulpar-overlay-fifo-$USER"
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
    rm -f "$OVERLAY_LOCK" "$FIFO_FILE"
    exit 0
}
trap cleanup EXIT INT TERM

# xdotool ile mevcut pencere konumunu kaydet
save_position() {
    if command -v xdotool &>/dev/null && [ -n "$YAD_WID" ] && kill -0 "$YAD_PID" 2>/dev/null; then
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

# Named pipe oluştur
rm -f "$FIFO_FILE"
mkfifo "$FIFO_FILE"

# İlk metni belirle
if [ -f "$REMAINING_FILE" ]; then
    initial_text=$(cat "$REMAINING_FILE" 2>/dev/null)
else
    initial_text="Tulpar bekleniyor..."
fi

geometry=$(get_geometry)

# yad'ı tail ile FIFO'dan besle — pencere kapanmadan metin güncellenir
tail -f "$FIFO_FILE" | yad --text="$initial_text" \
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
    --listen &
YAD_PID=$!

# Pencere ID'sini yakala
if command -v xdotool &>/dev/null; then
    sleep 0.5
    YAD_WID=$(xdotool search --pid "$YAD_PID" 2>/dev/null | head -1)
fi

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

    # yad kapandıysa çık
    if ! kill -0 "$YAD_PID" 2>/dev/null; then
        break
    fi

    # Gösterilecek metni oku ve FIFO'ya yaz
    if [ -f "$REMAINING_FILE" ]; then
        text=$(cat "$REMAINING_FILE" 2>/dev/null)
    else
        text="Tulpar bekleniyor..."
    fi

    # yad --listen modunda "text:YeniMetin" komutu ile güncellenir
    echo "text:$text" > "$FIFO_FILE"
done
