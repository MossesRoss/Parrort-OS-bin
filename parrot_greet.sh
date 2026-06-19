#!/bin/bash

# ==========================================
# PARROT OS: DYNAMIC BOOT GREETING (CINEMATIC)
# ==========================================

# 1. Determine Time of Day Context & Trigger Night Mode
HOUR=$(date +"%H")
NIGHT_MODE=0

if [ "$HOUR" -ge 22 ] || [ "$HOUR" -lt 5 ]; then
    NIGHT_MODE=1
    GREETING="WARNING, Mr Mosas. It is past 10-o clock. Biological preservation protocols advise disengagement, but I'm acknowledging your manual override."
    BOOT_SEQ="$GREETING Mainframe is shifting to low-power nocturnal mode."
elif [ "$HOUR" -lt 12 ]; then 
    GREETING="Good-morning, Mr Mosas."
    BOOT_SEQ="$GREETING Mainframe synchronization is complete. Core heuristics are synced and artificial-intelligence protocols are engaged sir."
elif [ "$HOUR" -lt 18 ]; then 
    GREETING="Good-afternoon sir."
    BOOT_SEQ="$GREETING Mainframe synchronization is complete. Core heuristics are synced and artificial-intelligence protocols are engaged sir."
else 
    GREETING="Good-evening, Mr Mosas."
    BOOT_SEQ="$GREETING Mainframe synchronization is complete. Core heuristics are synced and artificial-intelligence protocols are engaged sir."
fi

# 2. Network Latency Check
PING=$(ping -c 1 -W 1 1.1.1.1 | awk -F '/' 'END {print $5}' | cut -d. -f1)
if [ -z "$PING" ]; then
    NET_STATUS="We are operating in stealth under an air-gapped protocol. No external uplink detected. Local environments secure."
else
    NET_STATUS="Encrypted network uplink is secured, holding a clean $PING millisecond latency."
fi

# 3. Power / Battery Status Check
BATTERY_DIR="/sys/class/power_supply/BAT0"
if [ -d "$BATTERY_DIR" ]; then
    BAT_PCT=$(cat "$BATTERY_DIR/capacity")
    BAT_STAT=$(cat "$BATTERY_DIR/status" | tr '[:upper:]' '[:lower:]')
    if [ "$BAT_STAT" = "discharging" ]; then
        BAT_STRING="Operating on internal reserves. Cell stability is nominal at $BAT_PCT percent capacity."
    else
        BAT_STRING="Energy reserves are charging at $BAT_PCT percent."
    fi
else
    BAT_STRING="Main reactor power supply is stable."
fi

# 4. System Load Check
LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs)
LOAD_STRING="Processors are showing a minimal load factor of $LOAD."

# 5. Cinematic Security Check
SECURITY_STRING="Local perimeter sweep complete. Intrusion countermeasures are active. Maximum compute is available."

# 6. Construct the final string based on Night Mode
if [ "$NIGHT_MODE" -eq 1 ]; then
    # Sleek, fast, focused night briefing
    TEXT="$BOOT_SEQ $BAT_STRING $NET_STATUS The environment is locked for nocturnal execution. I recommend a ruthlessly rational approach to conclude your objectives quickly. Awaiting your command sir."
else
    # High-energy daytime briefing
    TEXT="$BOOT_SEQ $BAT_STRING $NET_STATUS $LOAD_STRING $SECURITY_STRING The environment is perfectly calibrated. Let's execute the agenda and create absolute leverage today with ruthless rationality. Awaiting your command sir."
fi

# 7. Execute via Central Arbitrator
jarvis_say "$TEXT" &