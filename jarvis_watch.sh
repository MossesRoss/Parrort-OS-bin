#!/bin/bash

# ==========================================
# PARROT OS: EXECUTION FAILURE TRIAGE
# ==========================================

if [ -z "$1" ]; then
    echo "Usage: jarvis_watch <command>"
    exit 1
fi

# 1. JARVIS Voice Synthesis Engine
PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

speak() {
    # Generate audio to RAM (/tmp) and play safely
    echo "$1" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_file /tmp/jarvis_triage.wav 2>/dev/null
    paplay /tmp/jarvis_triage.wav 2>/dev/null || aplay -q /tmp/jarvis_triage.wav 2>/dev/null
}

# 2. Command Execution
COMMAND_NAME="$1"

# Run the command passed by the user, keeping all standard output visible in the terminal
"$@"
EXIT_CODE=$?

# 3. Cinematic Briefing Evaluation
if [ $EXIT_CODE -eq 0 ]; then
    # Success protocol (Fast, subtle)
    TEXT="Execution of $COMMAND_NAME is complete Mr Mosas. Zero errors."
    speak "$TEXT"
else
    # Failure protocol (Urgent, pulls attention)
    TEXT="Pardon the interruption Mr Mosas. The $COMMAND_NAME process encountered a fatal exception and exited with code $EXIT_CODE. Awaiting your triage."
    speak "$TEXT"
fi

# Pass the original exit code back to the system
exit $EXIT_CODE