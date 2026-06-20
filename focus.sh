#!/bin/bash

# ==========================================
# PARROT OS: DEEP WORK / ISOLATION PROTOCOL
# ==========================================

MINUTES=${1:-90}
TIME_LEFT=$((MINUTES * 60))

DISTRACTIONS=("discord" "telegram-desktop" "slack" "skype" "whatsapp")

echo "[*] Neutralizing distraction vectors..."
for app in "${DISTRACTIONS[@]}"; do
    killall -9 "$app" 2>/dev/null
done

PING=$(ping -c 1 -W 1 1.1.1.1 2>/dev/null)
if [ -n "$PING" ]; then
    echo "[*] Uplink secured. Querying Gemini for execution mandate..."
    PROMPT="Act as an elite AI assistant to a CEO. Give me one short, highly aggressive, ruthlessly rational sentence about building leverage and executing deep work. Do not use quotes, special characters, or emojis."
    GEMINI_MANDATE=$(timeout 5 gemini "$PROMPT" 2>/dev/null)
    
    if [ -n "$GEMINI_MANDATE" ]; then
        MANDATE="$GEMINI_MANDATE"
    else
        MANDATE="Maximum compute is now routed to your foreground objectives."
    fi
else
    MANDATE="Operating in air-gapped stealth. Maximum compute is now routed to your foreground objectives."
fi

notify-send -u critical "DEEP WORK ENGAGED" "Comms severed. Isolation timer set for $MINUTES minutes."

# Starts the queue
~/.local/bin/jarvis_say "Focus protocol engaged Mr Mosas. External comms are severed and distraction nodes are neutralized. $MANDATE You have $MINUTES minutes of absolute isolation. Lets build."

echo "[*] Deep work protocol active for $MINUTES minutes."
while [ $TIME_LEFT -gt 0 ]; do
    echo -ne "\r\033[KTime remaining: $(date -u --date @$TIME_LEFT +%H:%M:%S)"
    sleep 1
    : $((TIME_LEFT--))
done

echo -e "\n[*] Protocol complete. Unlocking perimeter."
notify-send -u normal "DEEP WORK COMPLETE" "Focus block achieved."

~/.local/bin/jarvis_say "Time is up Mr Mosas. The focus block is complete. Local perimeter is unlocked and network traffic is permitted. Excellent execution today."
exit 0