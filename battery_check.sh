#!/bin/bash

# ==========================================
# PARROT OS: CEO BATTERY MONITOR
# ==========================================

export XDG_RUNTIME_DIR=/run/user/$(id -u)
export PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native"

# 1. Dependency Check
if ! command -v acpi &> /dev/null; then
    notify-send "BATTERY SCRIPT ERROR" "Please install 'acpi': sudo apt install acpi"
    exit 1
fi

# 2. State Tracking (Prevents repeating & Centralizes Logic)
WARNED_30=false
WARNED_12=false
WARNED_FULL=false
LAST_STATUS="Unknown"

# 3. Startup Confirmation
notify-send "Battery Monitor Active" "Heuristics online."

while true; do
    BAT_PER=$(acpi -b | grep -oP '\d+(?=%)' | sort -n | head -1)
    CURRENT_STATUS=$(acpi -b | grep -oP '(Discharging|Charging|Full|Not charging)' | head -1)

    # Safety: If ACPI failed to return a number
    if [[ -z "$BAT_PER" ]]; then
        sleep 30
        continue
    fi

    # --- GRID CONNECTION ALERTS (CENTRALIZED STATE TRACKING) ---
    if [ "$LAST_STATUS" != "Unknown" ] && [ "$LAST_STATUS" != "$CURRENT_STATUS" ]; then
        if [ "$CURRENT_STATUS" == "Discharging" ]; then
            ~/.local/bin/jarvis_say "Power source disconnected. Operating on internal reserves."
        elif [ "$CURRENT_STATUS" == "Charging" ]; then
            ~/.local/bin/jarvis_say "Main grid connected. Charging sequence initiated."
        fi
    fi
    LAST_STATUS="$CURRENT_STATUS"

    # --- CHARGING / FULL LOGIC ---
    if [ "$CURRENT_STATUS" != "Discharging" ]; then
        # Reset low battery warnings because we are plugged in
        WARNED_30=false
        WARNED_12=false

        # Alert when optimal capacity is reached
        if [ "$BAT_PER" -ge 95 ] && [ "$WARNED_FULL" = false ]; then
            ~/.local/bin/jarvis_say "Battery is at optimal capacity. You may disconnect the power source, sir."
            WARNED_FULL=true
        fi
        sleep 30
        continue
    fi

    WARNED_FULL=false # Reset full warning since we are draining

    # --- EMERGENCY SUSPEND (8%) ---
    if [ "$BAT_PER" -le 8 ]; then
        notify-send -u critical "CRITICAL BATTERY ($BAT_PER%)" "EMERGENCY SUSPEND."
        ~/.local/bin/jarvis_say --critical "Critical energy failure. Power reserves at $BAT_PER percent. Initiating emergency suspend protocol to preserve core systems. Goodbye sir."
        sleep 2 
        systemctl suspend
        sleep 60 

    # --- CRITICAL PRESSURE (12%) ---
    elif [ "$BAT_PER" -le 12 ] && [ "$WARNED_12" = false ]; then
        notify-send -u critical "⚠️ CRITICAL PRESSURE: $BAT_PER%" "Connect charger immediately."
        ~/.local/bin/jarvis_say --critical "Sir, I must strongly advise connecting to the main grid immediately. Core energy cells are critical at $BAT_PER percent. System shutdown is imminent."
        WARNED_12=true
        sleep 30

    # --- LOW WARNING (30%) ---
    elif [ "$BAT_PER" -le 30 ] && [ "$WARNED_30" = false ]; then
        notify-send -u normal "🔋 Battery at $BAT_PER%" "Find power source."
        ~/.local/bin/jarvis_say --critical "Pardon the interruption, Mr Mosas. Internal power reserves have dropped to $BAT_PER percent."
        WARNED_30=true
        sleep 60

    else
        # Standard polling interval
        sleep 30
    fi
done