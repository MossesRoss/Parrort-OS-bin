#!/bin/bash

# ==========================================
# PARROT OS: STEALTH PERIMETER MONITOR
# ==========================================

# Verify journalctl access
if ! journalctl -n 0 &>/dev/null; then
    notify-send -u critical "OVERWATCH FAILED" "Insufficient privileges to read system journal."
    exit 1
fi

LAST_ALERT=0
COOLDOWN=60

journalctl -f -n 0 -p warning -t sshd -t sudo -t login -t su 2>/dev/null | grep --line-buffered -i -E "failed password|authentication failure|incorrect password|FAILED" | while read -r line; do

    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - LAST_ALERT))

    if [ "$TIME_DIFF" -ge "$COOLDOWN" ]; then
        notify-send -u critical "SECURITY ALERT" "Unauthorized access attempt detected at perimeter."

        # Priority override: Security alerts cut through all other audio
        ~/.local/bin/jarvis_say --critical "Security alert Mr Mosas. Anomalous access attempt detected at the perimeter, Recommend immediate triage sir."

        LAST_ALERT=$CURRENT_TIME
    fi
done