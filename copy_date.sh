#!/bin/bash

# ==========================================
# JARVIS: DATE LOGGER
# ==========================================

# Get current date for clipboard
CLIPBOARD_DATE=$(date "+%A %b %d")

# Get human-readable date for JARVIS (e.g., "Friday, June 12")
VOICE_DATE=$(date "+%A, %B %-d")

# Copy to CopyQ (and clipboard)
echo -n "$CLIPBOARD_DATE" | copyq copy -

# Notify
notify-send -t 3000 "$CLIPBOARD_DATE" "Date logged, Mr. Mosses."

# JARVIS Voice Synthesis (Routed to Arbitrator)
~/.local/bin/jarvis_say "Today is $VOICE_DATE, Mr Mosas." &