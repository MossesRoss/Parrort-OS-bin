#!/bin/bash

# ==============================================================================
# JARVIS: AUTONOMOUS VOICE COMMAND ENGINE
# ==============================================================================

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

AUDIO_FILE="/tmp/jarvis_command.wav"
B64_FILE="/tmp/jarvis_command.b64"
PAYLOAD_FILE="/tmp/jarvis_payload.json"
API_KEY="$GEMINI_API_KEY"

if [ -z "$API_KEY" ]; then
    ~/.local/bin/jarvis_say "Critical error. API key is missing from the environment."
    exit 1
fi

# 1. Acoustic Feedback
~/.local/bin/jarvis_say "Online. You have the floor, sir."

# 2. Audio Capture (Tactical 6-Second Window)
arecord -d 6 -f S16_LE -r 16000 -c 1 -q "$AUDIO_FILE"

# 3. Processing Feedback
~/.local/bin/jarvis_say "Audio captured. Processing through the neural link."

# 4. Neural Routing (cURL + jq bypassing ARG_MAX)
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

# Hit the 2.5-Flash model directly
API_RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d @"$PAYLOAD_FILE" \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$API_KEY")

# Clean up temporary buffers immediately to preserve memory
rm -f "$AUDIO_FILE" "$B64_FILE" "$PAYLOAD_FILE"

# 5. Extract and Validate the Response
RAW_TEXT=$(echo "$API_RESPONSE" | jq -r '.candidates[0].content.parts[0].text // empty')

if [ -z "$RAW_TEXT" ]; then
    ~/.local/bin/jarvis_say "The uplink degraded or returned an empty payload. Aborting execution, Mosas."
    exit 1
fi

# Clean potential markdown JSON formatting returned by the API
CLEAN_JSON=$(echo "$RAW_TEXT" | sed -e 's/^```json//' -e 's/^```//' -e 's/```$//')

INTENT=$(echo "$CLEAN_JSON" | jq -r '.intent // "QUERY"')
TRANSCRIPTION=$(echo "$CLEAN_JSON" | jq -r '.transcription // empty')

if [ -z "$TRANSCRIPTION" ]; then
    ~/.local/bin/jarvis_say "I could not isolate your vocal signature. Discarding the buffer."
    exit 1
fi

# 6. The Execution Bifurcation
if [ "$INTENT" == "ACTION" ]; then
    ~/.local/bin/jarvis_say "Action intent recognized. Deploying autonomous agent to Workspace 9."
    
    # Switch to Workspace 9 and execute agy with the elite local model context
    AGY_PROMPT="You are JARVIS. Execute this filesystem/development task precisely via terminal commands: $TRANSCRIPTION"
    
    # x-terminal-emulator drops us into a visible shell.
    i3-msg "workspace 9; exec x-terminal-emulator -e bash -c 'agy \"$AGY_PROMPT\"; exec bash'" > /dev/null
    
else
    # For conversational queries, we hit the CLI headlessly and pipe it back to your speakers.
    # Strip markdown and quotes so it doesn't break the Piper audio engine.
    CLI_RESPONSE=$(agy "$TRANSCRIPTION" | sed -e 's/"//g' -e "s/'//g" -e 's/`//g' -e 's/\*//g' | tr '\n' ' ')
    
    ~/.local/bin/jarvis_say "$CLI_RESPONSE"
fi