#!/bin/bash

# ==========================================
# JARVIS: SECOND BRAIN EOD ROLLUP
# ==========================================

# Expose audio environment variables for headless execution
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

speak() {
    # Strip markdown, asterisks, quotes, and newlines to protect the audio buffer
    CLEAN_TEXT=$(echo "$1" | sed -e 's/"//g' -e "s/'//g" -e 's/`//g' -e 's/\*//g' | tr '\n' ' ')
    echo "$CLEAN_TEXT" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_raw 2>/dev/null | aplay -r 22050 -f S16_LE -t raw -q
}

speak "Evening, sir. Initiating end of day cognitive rollup. Compiling telemetry from today's operations."

# 1. Extract the last 20 copied items directly from the CopyQ database
CLIPBOARD_DATA=$(copyq eval 'for(i=0; i<20; ++i) print(read(i) + "\n---\n")' 2>/dev/null)

if [ -z "$CLIPBOARD_DATA" ]; then
    speak "No clipboard telemetry found for today. Disengaging."
    exit 0
fi

# 2. The Neural Prompt
SYSTEM_PROMPT="You are an AI assistant. Read the following raw clipboard data from the user's daily operations. Extract the core technical concepts or themes researched today. Write a highly concise, 3-sentence spoken executive briefing summarizing what was learned. Speak in plain English. No markdown. No code blocks."

# 3. Neural Synthesis (Qwen 3B)
SUMMARY=$(ollama run qwen2.5-coder:3b "$SYSTEM_PROMPT 

--- RAW DATA --- 
$CLIPBOARD_DATA")

if [ -n "$SUMMARY" ]; then
    speak "$SUMMARY"
    speak "Daily architecture logged. Disengage and rest."
else
    speak "Neural synthesis failed. The daily archive could not be compiled."
fi
