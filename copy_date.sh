#!/bin/bash

# ==========================================
# JARVIS: DATE LOGGER
# ==========================================

# Get current date for clipboard
CLIPBOARD_DATE=$(date "+%A %b %d")

# Get human-readable date for JARVIS (e.g., "Friday, June 12")
VOICE_DATE=$(date "+%A, %B %-d")

# Copy to clipboard with fallbacks
if command -v copyq &> /dev/null; then
    echo -n "$CLIPBOARD_DATE" | copyq copy -
elif command -v wl-copy &> /dev/null; then
    echo -n "$CLIPBOARD_DATE" | wl-copy
elif command -v xclip &> /dev/null; then
    echo -n "$CLIPBOARD_DATE" | xclip -selection clipboard
fi

# Notify
notify-send -t 3000 "$CLIPBOARD_DATE" "Date logged, Mr. Mosses."

# JARVIS Voice Synthesis (Routed to Arbitrator)
if [ -x ~/.local/bin/jarvis_say ]; then
    ~/.local/bin/jarvis_say "Today is $VOICE_DATE, Mr Mosas." &
fi