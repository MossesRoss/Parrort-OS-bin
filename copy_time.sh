#!/bin/bash

# ==========================================
# JARVIS: TIME LOGGER
# ==========================================

# Get current time for clipboard (24h or format of your choice)
CLIPBOARD_TIME=$(date "+%H:%M:%S")

# Get human-readable time for JARVIS (12-hour format e.g., "9 15 PM")
VOICE_TIME=$(date "+%-I %M %p") 

# Copy to CopyQ (and system clipboard) without a newline
echo -n "$CLIPBOARD_TIME" | copyq copy -

# Send visual notification
notify-send -t 3000 "$CLIPBOARD_TIME" "Time logged, Mr. Mosses."

# JARVIS Voice Synthesis (Routed to Arbitrator)
~/.local/bin/jarvis_say "The current time is $VOICE_TIME sir." &