#!/bin/bash

# ==========================================
# PARROT OS: PRE-SUSPEND CINEMATIC (DYNAMIC)
# ==========================================

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

HOUR=$(date +"%H")

if [ "$HOUR" -ge 20 ] || [ "$HOUR" -lt 5 ]; then
    CLOSING="Goodnight, sir."
else
    CLOSING="Entering standby mode."
fi

~/.local/bin/jarvis_say "System telemetry stored. Disengaging primary nodes and entering thermal preservation. $CLOSING"