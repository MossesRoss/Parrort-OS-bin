#!/bin/bash

# ==========================================
# PARROT OS: DEEP WORK / ISOLATION PROTOCOL
# ==========================================

# 1. Configuration & Argument Parsing
# Default to 90 minutes if no argument is provided. 
# Usage: ./focus.sh 60 (for a 60-minute session)
MINUTES=${1:-90}
TIME_LEFT=$((MINUTES * 60))

# JARVIS Voice Synthesis Engine
PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

speak() {
    # Suppress output and run synchronously
    echo "$1" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_raw 2>/dev/null | aplay -r 22050 -f S16_LE -t raw -q
}

# 2. Distraction Neutralization
# Add or remove applications from this array as needed
DISTRACTIONS=("discord" "telegram-desktop" "slack" "skype" "whatsapp")

echo "[*] Neutralizing distraction vectors..."
for app in "${DISTRACTIONS[@]}"; do
    killall -9 "$app" 2>/dev/null
done

# Optional: Enable Linux Do Not Disturb (GNOME/MATE/XFCE variant depending on your specific Parrot flavor)
# gsettings set org.gnome.desktop.notifications show-banners false 2>/dev/null

# 3. Dynamic AI Execution Mandate (Gemini CLI Integration)
# We test the network silently. If online, we query Gemini for a unique operational mandate.
PING=$(ping -c 1 -W 1 1.1.1.1 2>/dev/null)
if [ -n "$PING" ]; then
    echo "[*] Uplink secured. Querying Gemini for execution mandate..."
    
    # Adjust this command based on your exact Gemini CLI syntax.
    # We ask for a short, punctuation-light sentence so JARVIS speaks it fluidly.
    PROMPT="Act as an elite AI assistant to a CEO. Give me one short, highly aggressive, ruthlessly rational sentence about building leverage and executing deep work. Do not use quotes, special characters, or emojis."
    
    # Timeout ensures we don't wait forever if the API hangs
    GEMINI_MANDATE=$(timeout 5 gemini "$PROMPT" 2>/dev/null)
    
    if [ -n "$GEMINI_MANDATE" ]; then
        MANDATE="$GEMINI_MANDATE"
    else
        MANDATE="Maximum compute is now routed to your foreground objectives."
    fi
else
    MANDATE="Operating in air-gapped stealth. Maximum compute is now routed to your foreground objectives."
fi

# 4. Lockdown Initiation
notify-send -u critical "DEEP WORK ENGAGED" "Comms severed. Isolation timer set for $MINUTES minutes."

# The intro briefing. Note the phonetic tuning "Mr Mosas" for fluid delivery.
START_TEXT="Focus protocol engaged Mr Mosas. External comms are severed and distraction nodes are neutralized. $MANDATE You have $MINUTES minutes of absolute isolation. Lets build."

speak "$START_TEXT"

# 5. The Isolation Timer
# A silent countdown in the terminal showing remaining time for visual reference.
echo "[*] Deep work protocol active for $MINUTES minutes."
while [ $TIME_LEFT -gt 0 ]; do
    # \r goes to start of line, \033[K clears the line to prevent visual glitches
    echo -ne "\r\033[KTime remaining: $(date -u --date @$TIME_LEFT +%H:%M:%S)"
    sleep 1
    : $((TIME_LEFT--))
done

# 6. Re-entry & Completion
echo -e "\n[*] Protocol complete. Unlocking perimeter."
notify-send -u normal "DEEP WORK COMPLETE" "Focus block achieved. Awaiting further instructions."

# Optional: Disable Linux Do Not Disturb
# gsettings set org.gnome.desktop.notifications show-banners true 2>/dev/null

END_TEXT="Time is up Mr Mosas. The focus block is complete. Local perimeter is unlocked and network traffic is permitted. Excellent execution today."
speak "$END_TEXT"

exit 0