#!/bin/bash

# ==========================================
# BATTERY MONITOR — Silent Prompt Alerts
# ==========================================

export XDG_RUNTIME_DIR=/run/user/$(id -u)

# 1. Dependency Check
if ! command -v acpi &> /dev/null; then
    notify-send "BATTERY SCRIPT ERROR" "Please install 'acpi': sudo apt install acpi"
    exit 1
fi

# 2. State Tracking (one-shot flags per threshold)
WARNED_70=false
WARNED_50=false
WARNED_30=false
WARNED_12=false


while true; do
    BAT_PER=$(acpi -b | grep -oP '\d+(?=%)' | sort -n | head -1)
    CURRENT_STATUS=$(acpi -b | grep -oP '(Discharging|Charging|Full|Not charging)' | head -1)

    # Safety: If ACPI failed to return a number
    if [[ -z "$BAT_PER" ]]; then
        sleep 30
        continue
    fi

    # --- CHARGING / NOT DISCHARGING / PLUGGED IN — reset warnings & do nothing ---
    if [ "$CURRENT_STATUS" != "Discharging" ] || acpi -a | grep -iq "on-line"; then
        WARNED_70=false
        WARNED_50=false
        WARNED_30=false
        WARNED_12=false
        sleep 30
        continue
    fi

    # --- EMERGENCY SUSPEND (9%) ---
    if [ "$BAT_PER" -le 9 ]; then
        notify-send -u critical "⛔ EMERGENCY SUSPEND ($BAT_PER%)" "Battery critically low. Suspending now."
        ~/.local/bin/jarvis_say --critical "Critical energy failure. Power reserves at $BAT_PER percent. Initiating emergency suspend protocol to preserve core systems. Goodbye sir."
        sleep 2
        systemctl suspend
        sleep 60

    # --- CRITICAL (12%) ---
    elif [ "$BAT_PER" -le 12 ] && [ "$WARNED_12" = false ]; then
        notify-send -u critical "🔴 CRITICAL: $BAT_PER%" "Connect charger immediately!"
        ~/.local/bin/jarvis_say --critical "Sir I must strongly advise connecting to the main grid immediately. Core energy cells are critical at $BAT_PER percent. System shutdown is imminent."
        WARNED_12=true
        sleep 30

    # --- CRITICAL (30%) ---
    elif [ "$BAT_PER" -le 30 ] && [ "$WARNED_30" = false ]; then
        notify-send -u critical "🟠 Battery Low: $BAT_PER%" "Battery is getting critical. Find a power source."
        ~/.local/bin/jarvis_say --critical "Pardon the interruption sir. Internal power reserves have dropped to $BAT_PER percent."
        WARNED_30=true
        sleep 30

    # --- WARNING (50%) ---
    elif [ "$BAT_PER" -le 50 ] && [ "$WARNED_50" = false ]; then
        notify-send -u normal "🟡 Battery at $BAT_PER%" "Consider plugging in soon."
        ~/.local/bin/jarvis_say "Battery at $BAT_PER percent sir. Consider plugging in."
        WARNED_50=true
        sleep 30

    # --- INFO (70%) ---
    elif [ "$BAT_PER" -le 70 ] && [ "$WARNED_70" = false ]; then
        notify-send -u low "🔋 Battery at $BAT_PER%" "Running on battery."
        ~/.local/bin/jarvis_say "Battery at $BAT_PER percent. Running on internal reserves."
        WARNED_70=true
        sleep 60

    else
        sleep 30
    fi
done