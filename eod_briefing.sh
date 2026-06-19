#!/bin/bash

# ==========================================
# PARROT OS: EOD BIOLOGICAL PRESERVATION
# ==========================================

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

# Telemetry Extraction
UPTIME=$(uptime -p | sed 's/up //')

notify-send -u critical "EOD PROTOCOL" "Execution threshold reached. Initiate rest."

jarvis_say "Evening briefing Mr Mosas. System uptime is currently $UPTIME. You have reached the execution threshold for today. I strongly advise disengaging from the mainframe and initiating sleep protocols to maintain peak biological performance for tomorrow's agenda. Flawless work today, sir."