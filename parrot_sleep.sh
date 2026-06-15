#!/bin/bash

# ==========================================
# PARROT OS: PRE-SUSPEND CINEMATIC (DYNAMIC)
# ==========================================

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

# Time context logic
HOUR=$(date +"%H")

# If time is between 8 PM (20) and 4 AM (04)
if [ "$HOUR" -ge 20 ] || [ "$HOUR" -lt 5 ]; then
    CLOSING="Goodnight, sir."
else
    CLOSING="Entering standby mode."
fi

TEXT="System telemetry stored. Disengaging primary nodes and entering thermal preservation. $CLOSING"

echo "$TEXT" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_raw 2>/dev/null | aplay -r 22050 -f S16_LE -t raw -q
