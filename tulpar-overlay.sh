#!/bin/bash
# Tulpar - Masaüstü Sayaç Overlay
# Kalan süreyi masaüstünde gösterir

CONFIG_DIR="$HOME/.config/tulpar"
REMAINING_FILE="$CONFIG_DIR/.remaining"
OVERLAY_LOCK="/tmp/tulpar-overlay-$USER.lock"
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

cleanup() {
    [ -n "$YAD_PID" ] && kill "$YAD_PID" 2>/dev/null
    rm -f "$OVERLAY_LOCK"
    exit 0
}
trap cleanup EXIT INT TERM

while true; do
    if [ -f "$REMAINING_FILE" ]; then
        text=$(cat "$REMAINING_FILE" 2>/dev/null)
    else
        text="Tulpar bekleniyor..."
    fi

    # Eski yad penceresini kapat
    if [ -n "$YAD_PID" ] && kill -0 "$YAD_PID" 2>/dev/null; then
        kill "$YAD_PID" 2>/dev/null
        wait "$YAD_PID" 2>/dev/null
    fi

    # Yeni yad penceresi aç
    yad --fixed \
        --text="$text" \
        --no-buttons \
        --undecorated \
        --skip-taskbar \
        --on-top \
        --sticky \
        --close-on-unfocus=false \
        --no-focus \
        --geometry=+20+20 \
        --borders=8 \
        --text-align=center \
        --fore="#FFFFFF" \
        --back="#222222" \
        --fontname="Sans Bold 13" \
        --timeout="$((UPDATE_INTERVAL + 2))" \
        --timeout-indicator=none &
    YAD_PID=$!

    sleep "$UPDATE_INTERVAL"
done
