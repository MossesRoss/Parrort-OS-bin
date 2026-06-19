#!/bin/bash

# ==========================================
# JARVIS: THE DOPAMINE WARDEN (KILLSWITCH)
# ==========================================

BLACKLIST="(YouTube|Twitter|X|Reddit|Netflix|Instagram|Facebook|TikTok)"

VIOLATION_SECONDS=0
CHECK_INTERVAL=10

while true; do
    ACTIVE_WINDOW=$(xdotool getactivewindow getwindowname 2>/dev/null)

    if echo "$ACTIVE_WINDOW" | grep -iE "$BLACKLIST" > /dev/null; then
        VIOLATION_SECONDS=$((VIOLATION_SECONDS + CHECK_INTERVAL))

        if [ "$VIOLATION_SECONDS" -eq 300 ]; then
            ~/.local/bin/~/.local/bin/jarvis_say "Warning Mr Mosas. You have been on a distraction node for five minutes. Please realign with foreground objectives."
        fi

        if [ "$VIOLATION_SECONDS" -eq 600 ]; then
            # Escalated warning cuts through normal audio
            ~/.local/bin/~/.local/bin/jarvis_say --critical "Critical warning. Objective alignment is degrading. Close the browser immediately or execution protocols will engage."
        fi

        if [ "$VIOLATION_SECONDS" -ge 720 ]; then
            ~/.local/bin/~/.local/bin/jarvis_say --critical "Time limit exceeded. Assassinating process."
            
            WINDOW_ID=$(xdotool getactivewindow)
            xdotool windowkill "$WINDOW_ID"
            
            VIOLATION_SECONDS=0
        fi
    else
        if [ "$VIOLATION_SECONDS" -gt 0 ]; then
            VIOLATION_SECONDS=0
        fi
    fi

    sleep $CHECK_INTERVAL
done