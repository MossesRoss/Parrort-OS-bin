#!/bin/bash

# ==========================================
# PARROT OS: JARVIS HIGHLIGHT READER
# ==========================================

# 1. Killswitch Protocol
if [ "$1" = "stop" ]; then
    # Kills any active speech pipelines across the system
    pkill -f piper 2>/dev/null
    pkill -f aplay 2>/dev/null
    exit 0
fi

# 2. Text Extraction
TEXT=$(copyq read 0)

if [ -z "$TEXT" ]; then
    notify-send -u normal "JARVIS" "No text found in clipboard to read."
    exit 1
fi

notify-send -u low "JARVIS" "Audio synthesis initiated."

~/.local/bin/jarvis_say "$TEXT" &