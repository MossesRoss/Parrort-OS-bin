#!/bin/bash

# ==========================================
# PARROT OS: STEALTH PERIMETER MONITOR
# ==========================================

LOG_FILE="/var/log/auth.log"

if [ ! -r "$LOG_FILE" ]; then
    notify-send -u critical "OVERWATCH FAILED" "Insufficient privileges to read auth.log."
    exit 1
fi

LAST_ALERT=0
COOLDOWN=60 

notify-send "Overwatch Engaged" "Perimeter is secure."

tail -n0 -F "$LOG_FILE" 2>/dev/null | grep --line-buffered -i -E "failed password|authentication failure|incorrect password" | while read -r line; do
    
    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - LAST_ALERT))
    
    if [ "$TIME_DIFF" -ge "$COOLDOWN" ]; then
        notify-send -u critical "SECURITY ALERT" "Unauthorized access attempt detected at perimeter."
        
        # Priority override: Security alerts cut through all other audio
        ~/.local/bin/~/.local/bin/jarvis_say --critical "Security alert Mr Mosas. Anomalous access attempt detected at the perimeter. Recommend immediate triage."
        
        LAST_ALERT=$CURRENT_TIME
    fi
done