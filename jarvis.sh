#!/bin/bash

# ==============================================================================
# JARVIS: AUTONOMOUS VOICE COMMAND ENGINE (VERBOSE MODE)
# ==============================================================================

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

AUDIO_FILE="/tmp/jarvis_command.wav"
B64_FILE="/tmp/jarvis_command.b64"
PAYLOAD_FILE="/tmp/jarvis_payload.json"
LOG_FILE="/tmp/jarvis_debug.log"
API_KEY="$GEMINI_API_KEY"

# Initialize fresh log
echo "=== JARVIS EXECUTION LOG: $(date) ===" > "$LOG_FILE"

if [ -z "$API_KEY" ]; then
    echo "[!] ERROR: API key missing." >> "$LOG_FILE"
    ~/.local/bin/jarvis_say "Critical error. API key is missing from the environment."
    exit 1
fi

# 1. Acoustic Feedback
~/.local/bin/jarvis_say "Online. You have the floor, sir."

# 2. Audio Capture (Tactical 6-Second Window)
echo "[*] Capturing 6-second tactical audio window..." >> "$LOG_FILE"
arecord -d 6 -f S16_LE -r 16000 -c 1 -q "$AUDIO_FILE"

# 3. Processing Feedback
~/.local/bin/jarvis_say "Processing through the neural link."

# 4. Neural Routing (Switched to 3.1 Flash-Lite for 500 RPD limit)
base64 -w 0 "$AUDIO_FILE" > "$B64_FILE"

jq -n --rawfile b64 "$B64_FILE" '{
  "contents": [{
    "parts": [
      {"text": "Listen to the audio. 1. Transcribe it perfectly. 2. Determine if it is a QUERY or ACTION. Output strictly in JSON format: {\"transcription\": \"what they said\", \"intent\": \"QUERY|ACTION\"}"},
      {"inline_data": {"mime_type": "audio/wav", "data": $b64}}
    ]
  }],
  "generationConfig": {"response_mime_type": "application/json"}
}' > "$PAYLOAD_FILE"

echo "[*] Transmitting payload to Gemini 3.1 Flash Lite..." >> "$LOG_FILE"

API_RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d @"$PAYLOAD_FILE" \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=$API_KEY")

echo "[*] Raw API Response:" >> "$LOG_FILE"
echo "$API_RESPONSE" >> "$LOG_FILE"

# Clean up temporary buffers
rm -f "$AUDIO_FILE" "$B64_FILE" "$PAYLOAD_FILE"

# 5. Extract and Validate the Response
RAW_TEXT=$(echo "$API_RESPONSE" | jq -r '.candidates[0].content.parts[0].text // empty')

if [ -z "$RAW_TEXT" ]; then
    echo "[!] ERROR: Empty response from API. Check limits or network." >> "$LOG_FILE"
    ~/.local/bin/jarvis_say "The uplink degraded or returned an empty payload."
    exit 1
fi

CLEAN_JSON=$(echo "$RAW_TEXT" | sed -e 's/^```json//' -e 's/^```//' -e 's/```$//')
INTENT=$(echo "$CLEAN_JSON" | jq -r '.intent // "QUERY"')
TRANSCRIPTION=$(echo "$CLEAN_JSON" | jq -r '.transcription // empty')

echo "[*] Parsed Intent: $INTENT" >> "$LOG_FILE"
echo "[*] Parsed Transcription: $TRANSCRIPTION" >> "$LOG_FILE"

if [ -z "$TRANSCRIPTION" ]; then
    ~/.local/bin/jarvis_say "I could not isolate your vocal signature. Discarding the buffer."
    exit 1
fi

# 6. The Execution Bifurcation
if [ "$INTENT" == "ACTION" ]; then
    ~/.local/bin/jarvis_say "Action intent recognized. Deploying agent."
    
    # Bulletproof Execution: Write prompt to a file to prevent quote explosions
    echo "You are JARVIS. Execute this filesystem/development task precisely via terminal commands: $TRANSCRIPTION" > /tmp/jarvis_yolo.txt
    
    # Create a dynamic execution script that forces the environment to load
    cat << 'EOF' > /tmp/jarvis_exec.sh
#!/bin/bash
# Force load the user environment so 'agy' is found
source ~/.bashrc
source ~/.profile 2>/dev/null
echo "--- JARVIS AGENTIC TERMINAL ---"
PROMPT=$(cat /tmp/jarvis_yolo.txt)
echo "Executing: $PROMPT"
echo "-------------------------------"
# Added -p flag to force one-shot prompt execution. Append your YOLO flag here if needed (e.g., agy -p "$PROMPT" -y)
agy -p "$PROMPT"
echo "Execution complete. Dropping to shell."
exec bash
EOF
    chmod +x /tmp/jarvis_exec.sh

    echo "[*] Triggering i3 Workspace 9 and spawning terminal..." >> "$LOG_FILE"
    
    # Execute the bulletproof wrapper script
    # NOTE: Change 'x-terminal-emulator' to 'kitty' or 'alacritty' if it still fails to open
    i3-msg "workspace 9; exec x-terminal-emulator -e /tmp/jarvis_exec.sh" >> "$LOG_FILE" 2>&1
    
else
    echo "[*] Executing headlessly for conversational query..." >> "$LOG_FILE"
    
    # 1. Semantic Constraint: Force plain English
    STRICT_PROMPT="$TRANSCRIPTION. Answer in plain spoken English only. No markdown, no asterisks, no hashes, no special formatting."
    
    # 2. Sanitization Pipeline: Strip out all residual '#' and formatting artifacts
    CLI_RESPONSE=$(bash -ic "agy -p \"$STRICT_PROMPT\"" | sed -e 's/"//g' -e "s/'//g" -e 's/`//g' -e 's/\*//g' -e 's/#//g' | tr '\n' ' ')
    
    ~/.local/bin/jarvis_say "$CLI_RESPONSE"
fi