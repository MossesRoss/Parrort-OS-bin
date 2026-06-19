#!/bin/bash

# ==========================================
# SYSTEM: VOLUME CONTROL
# ==========================================
# Usage: ./volume.sh [up|down|mute]

case "$1" in
    up)   wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.5 ;;
    down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
esac

STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
VOL=$(echo "$STATUS" | awk '{print int($2 * 100)}')

if [[ "$STATUS" == *"[MUTED]"* ]]; then
    TEXT="Jarvis: Muted System"
else
    TEXT="Jarvis: Volume set to ${VOL}%"
fi

# Close previous notifications to prevent stacking
dunstctl close-all

# Send pure text notification (No -i icon flag = No terminal spam)
dunstify -u low -h int:value:"$VOL" "$TEXT"