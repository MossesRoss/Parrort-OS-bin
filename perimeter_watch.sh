#!/bin/bash

# ==========================================
# PARROT OS: STEALTH PERIMETER MONITOR
# ==========================================

LOG_FILE="/var/log/auth.log"

# 1. Permission Check
if [ ! -r "$LOG_FILE" ]; then
    notify-send -u critical "OVERWATCH FAILED" "Insufficient privileges to read auth.log."
    exit 1
fi

# 2. JARVIS Voice Synthesis Engine
PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

speak() {
    # Generate audio to RAM and play safely
    echo "$1" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_file /tmp/jarvis_security.wav 2>/dev/null
    paplay /tmp/jarvis_security.wav 2>/dev/null || aplay -q /tmp/jarvis_security.wav 2>/dev/null
}

# 3. State Tracking (Audio Cooldown)
LAST_ALERT=0
COOLDOWN=60 # Seconds between audio warnings to prevent spam during brute force attacks

# 4. Startup Confirmation
notify-send "Overwatch Engaged" "Perimeter is secure."

# 5. Continuous Silent Monitoring
# tail -n0 ensures it only watches new events, not historical ones.
# grep --line-buffered ensures events pass through instantly.
tail -n0 -F "$LOG_FILE" 2>/dev/null | grep --line-buffered -i -E "failed password|authentication failure|incorrect password" | while read -r line; do
    
    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - LAST_ALERT))
    
    if [ "$TIME_DIFF" -ge "$COOLDOWN" ]; then
        notify-send -u critical "SECURITY ALERT" "Unauthorized access attempt detected at perimeter."
        
        # Phonetic tuning for cinematic delivery
        speak "Security alert Mr Mosas. Anomalous access attempt detected at the perimeter. Recommend immediate triage."
        
        LAST_ALERT=$CURRENT_TIME
    fi
done