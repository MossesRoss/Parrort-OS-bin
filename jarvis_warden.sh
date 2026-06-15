#!/bin/bash

# ==========================================
# JARVIS: THE DOPAMINE WARDEN (KILLSWITCH)
# ==========================================

PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

# The Threat Matrix (Pipe-separated Regex)
BLACKLIST="(YouTube|Twitter|X|Reddit|Netflix|Instagram|Facebook|TikTok)"

# Telemetry
VIOLATION_SECONDS=0
CHECK_INTERVAL=10

speak() {
    echo "$1" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_raw 2>/dev/null | aplay -r 22050 -f S16_LE -t raw -q &
}

while true; do
    # Capture the active window title. Fails gracefully if the workspace is empty.
    ACTIVE_WINDOW=$(xdotool getactivewindow getwindowname 2>/dev/null)

    # Check if the active window matches the blacklist
    if echo "$ACTIVE_WINDOW" | grep -iE "$BLACKLIST" > /dev/null; then
        VIOLATION_SECONDS=$((VIOLATION_SECONDS + CHECK_INTERVAL))

        # Threshold 1: 5 Minutes (300 seconds)
        if [ "$VIOLATION_SECONDS" -eq 300 ]; then
            speak "Warning Mr Mosas. You have been on a distraction node for five minutes. Please realign with foreground objectives."
        fi

        # Threshold 2: 10 Minutes (600 seconds)
        if [ "$VIOLATION_SECONDS" -eq 600 ]; then
            speak "Critical warning. Objective alignment is degrading. Close the browser immediately or execution protocols will engage."
        fi

        # The Killswitch: 12 Minutes (720 seconds)
        if [ "$VIOLATION_SECONDS" -ge 720 ]; then
            speak "Time limit exceeded. Assassinating process."
            
            # Identify the specific violating window and ruthlessly terminate it
            WINDOW_ID=$(xdotool getactivewindow)
            xdotool windowkill "$WINDOW_ID"
            
            VIOLATION_SECONDS=0
        fi
    else
        # If you switch back to VS Code, Terminal, or a productive node, the timer resets.
        if [ "$VIOLATION_SECONDS" -gt 0 ]; then
            VIOLATION_SECONDS=0
        fi
    fi

    sleep $CHECK_INTERVAL
done
