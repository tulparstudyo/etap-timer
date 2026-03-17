#!/bin/bash
# Tulpar - Masaüstü Sayaç Overlay
# Kalan süreyi masaüstünde gösterir

CONFIG_DIR="$HOME/.config/tulpar"
REMAINING_FILE="$CONFIG_DIR/.remaining"
OVERLAY_LOCK="/tmp/tulpar-overlay-$USER.lock"

# Single instance kontrolü
if [ -f "$OVERLAY_LOCK" ]; then
    existing_pid=$(cat "$OVERLAY_LOCK")
    if kill -0 "$existing_pid" 2>/dev/null; then
        exit 0
    fi
    rm -f "$OVERLAY_LOCK"
fi

echo $$ > "$OVERLAY_LOCK"
trap 'rm -f "$OVERLAY_LOCK"; exit 0' EXIT INT TERM

# yad yoksa çık
if ! command -v yad &>/dev/null; then
    exit 1
fi

PIPE="$CONFIG_DIR/.overlay_pipe"
rm -f "$PIPE"
mkfifo "$PIPE"

# yad text-info penceresi — şeffaf, her zaman üstte, sağ alt köşede
tail -f "$PIPE" | yad --text-info \
    --title="" \
    --no-buttons \
    --undecorated \
    --skip-taskbar \
    --on-top \
    --sticky \
    --geometry=220x40-20-40 \
    --fore="#FFFFFF" \
    --back="#333333" \
    --fontname="Sans Bold 13" \
    --tail \
    --no-focus &

YAD_PID=$!

cleanup() {
    kill "$YAD_PID" 2>/dev/null
    wait "$YAD_PID" 2>/dev/null
    rm -f "$PIPE" "$OVERLAY_LOCK"
    exit 0
}
trap cleanup EXIT INT TERM

sleep 1

while kill -0 "$YAD_PID" 2>/dev/null; do
    if [ -f "$REMAINING_FILE" ]; then
        text=$(cat "$REMAINING_FILE" 2>/dev/null)
    else
        text="Tulpar bekleniyor..."
    fi
    # Satırı temizleyip yeniden yaz
    echo -e "\f$text" > "$PIPE" 2>/dev/null || break
    sleep 5
done
