#!/bin/bash

# ==========================================
# PARROT OS: EOD BIOLOGICAL PRESERVATION
# ==========================================

# 1. Environment Injection (CRITICAL FOR CRON)
# Cron has no display or audio context by default. We must force it.
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

# 2. JARVIS Voice Synthesis Engine
PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

speak() {
    # Generate audio to RAM and play safely
    echo "$1" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_file /tmp/jarvis_eod.wav 2>/dev/null
    paplay /tmp/jarvis_eod.wav 2>/dev/null || aplay -q /tmp/jarvis_eod.wav 2>/dev/null
}

# 3. Telemetry Extraction
# Gets clean uptime (e.g., "4 hours, 12 minutes")
UPTIME=$(uptime -p | sed 's/up //')

# 4. The Briefing
notify-send -u critical "EOD PROTOCOL" "Execution threshold reached. Initiate rest."

TEXT="Evening briefing Mr Mosas. System uptime is currently $UPTIME. You have reached the execution threshold for today. I strongly advise disengaging from the mainframe and initiating sleep protocols to maintain peak biological performance for tomorrow's agenda. Flawless work today, sir."

speak "$TEXT"