#!/bin/bash

# ==========================================
# PARROT OS: PRE-SHUTDOWN CINEMATIC
# ==========================================

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

~/.local/bin/~/.local/bin/jarvis_say "All primary objectives completed. Severing mainframe connection and initiating total hardware shutdown. Flawless execution today, Mr Mosas."