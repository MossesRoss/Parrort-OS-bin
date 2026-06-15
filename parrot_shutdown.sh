#!/bin/bash

# ==========================================
# PARROT OS: PRE-SHUTDOWN CINEMATIC
# ==========================================

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

TEXT="All primary objectives completed. Severing mainframe connection and initiating total hardware shutdown. Flawless execution today, Mr Mosas."

echo "$TEXT" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_raw 2>/dev/null | aplay -r 22050 -f S16_LE -t raw -q
