#!/bin/bash

# ==========================================
# JARVIS: SECOND BRAIN EOD ROLLUP
# ==========================================

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

jarvis_say "Evening, sir. Initiating end of day cognitive rollup. Compiling telemetry from today's operations."

# 1. Extract clipboard data
CLIPBOARD_DATA=$(copyq eval 'for(i=0; i<20; ++i) print(read(i) + "\n---\n")' 2>/dev/null)

if [ -z "$CLIPBOARD_DATA" ]; then
    jarvis_say "No clipboard telemetry found for today. Disengaging."
    exit 0
fi

# 2. The Neural Prompt
SYSTEM_PROMPT="You are an AI assistant. Read the following raw clipboard data from the user's daily operations. Extract the core technical concepts or themes researched today. Write a highly concise, 3-sentence spoken executive briefing summarizing what was learned. Speak in plain English. No markdown. No code blocks."

# 3. Neural Synthesis
SUMMARY=$(ollama run qwen2.5-coder:3b "$SYSTEM_PROMPT 

--- RAW DATA --- 
$CLIPBOARD_DATA")

if [ -n "$SUMMARY" ]; then
    jarvis_say "$SUMMARY"
    jarvis_say "Daily architecture logged. Disengage and rest."
else
    jarvis_say "Neural synthesis failed. The daily archive could not be compiled."
fi