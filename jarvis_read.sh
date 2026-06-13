#!/bin/bash

# ==========================================
# PARROT OS: JARVIS HIGHLIGHT READER
# ==========================================

PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

# 1. Killswitch Protocol
# If the script is passed 'stop', we terminate all active reading immediately.
if [ "$1" = "stop" ]; then
    killall piper aplay paplay 2>/dev/null
    exit 0
fi

# 2. Text Extraction
# Grabs the currently highlighted text (Primary Selection) or the Clipboard
# copyq read 0 gets the top item from your clipboard manager
TEXT=$(copyq read 0)

if [ -z "$TEXT" ]; then
    notify-send -u normal "JARVIS" "No text found in clipboard to read."
    exit 1
fi

# 3. Clean Execution Environment
# Silence any currently playing JARVIS audio before starting the new text
killall piper aplay paplay 2>/dev/null

# 4. Neural Synthesis (Streaming Mode)
# For long stories, we don't save to a file. We pipe raw data directly to ALSA 
# so JARVIS starts speaking immediately, even if the text is 5 pages long.
echo "$TEXT" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_raw 2>/dev/null | aplay -r 22050 -f S16_LE -t raw -q &

# 5. Visual Confirmation
notify-send -u low "JARVIS Reading" "Audio synthesis initiated."