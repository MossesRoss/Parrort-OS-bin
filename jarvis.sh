#!/bin/bash

# ==============================================================================
# JARVIS: AUTONOMOUS VOICE COMMAND ENGINE
# ==============================================================================

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

AUDIO_FILE="/tmp/jarvis_command.wav"
API_KEY="$GEMINI_API_KEY" # Make sure this is exported in your environment!

# 1. Acoustic Feedback
~/.local/bin/jarvis_say "Yes sir?"

# 2. Audio Capture (Tactical 6-Second Window)
# Uses native ALSA. No Sox required. -d 6 limits recording to exactly 6 seconds.
arecord -d 6 -f S16_LE -r 16000 -c 1 -q "$AUDIO_FILE"

# 3. Processing Feedback
~/.local/bin/jarvis_say "Processing."

# 4. Neural Routing (Python API Request to Gemini 1.5 Flash for FAST routing)
export PY_API_KEY="$API_KEY"
export PY_AUDIO_FILE="$AUDIO_FILE"

ROUTER_DATA=$(python3 << 'EOF'
import base64
import json
import urllib.request
import sys
import os

API_KEY = os.environ.get("PY_API_KEY")
FILE_PATH = os.environ.get("PY_AUDIO_FILE")

try:
    with open(FILE_PATH, 'rb') as f:
        audio_b64 = base64.b64encode(f.read()).decode('utf-8')
except Exception:
    print("ERROR=True")
    sys.exit(0)

prompt = """
Listen to the audio. 
1. Transcribe it perfectly. 
2. Determine if it is a 'QUERY' (answering a question, summarizing) or 'ACTION' (creating files, coding, system commands, terminal tasks). 
Output strictly in JSON format: {"transcription": "what they said", "intent": "QUERY|ACTION"}
"""

payload = {
    "contents": [{"parts": [
        {"text": prompt},
        {"inline_data": {"mime_type": "audio/wav", "data": audio_b64}}
    ]}],
    "generationConfig": {"response_mime_type": "application/json"}
}

req = urllib.request.Request(
    f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={API_KEY}",
    data=json.dumps(payload).encode('utf-8'),
    headers={'Content-Type': 'application/json'},
    method='POST'
)

try:
    with urllib.request.urlopen(req) as response:
        res_data = json.loads(response.read().decode())
        content_text = res_data['candidates'][0]['content']['parts'][0]['text']
        
        # Clean JSON blocks if the API wraps it in markdown
        if content_text.startswith('```json'):
            content_text = content_text.strip('```json').strip('```').strip()
            
        parsed = json.loads(content_text)
        
        # Escape quotes for bash evaluation
        safe_transcription = parsed.get("transcription", "").replace('"', '\\"')
        safe_intent = parsed.get("intent", "QUERY")
        
        print(f'INTENT="{safe_intent}"\nTRANSCRIPTION="{safe_transcription}"')
except Exception as e:
    print("ERROR=True")
EOF
)

# 5. Evaluate Python Output
eval "$ROUTER_DATA"

if [ "$ERROR" == "True" ] || [ -z "$TRANSCRIPTION" ]; then
    ~/.local/bin/jarvis_say "Transcription failed or no audio detected. aborting the opperation sir"
    rm -f "$AUDIO_FILE"
    exit 1
fi

# 6. The Execution Bifurcation
if [ "$INTENT" == "ACTION" ]; then
    ~/.local/bin/jarvis_say "Routing autonomous agent to Workspace 9, sir."
    
    # Switch to Workspace 9 and execute agy with the elite local model context
    # We prefix the prompt to ensure the CLI knows it is executing an OS-level task
    AGY_PROMPT="You are JARVIS. Execute this filesystem/development task precisely via terminal commands: $TRANSCRIPTION"
    
    # x-terminal-emulator drops us into a visible shell. The user can press Ctrl+Y to execute the YOLO commands.
    i3-msg "workspace 9; exec x-terminal-emulator -e bash -c 'agy \"$AGY_PROMPT\"; exec bash'" > /dev/null
    
else
    # For conversational queries, we hit the CLI headlessly and pipe it back to your speakers.
    CLI_RESPONSE=$(agy "$TRANSCRIPTION")
    
    ~/.local/bin/jarvis_say "$CLI_RESPONSE"
fi

# Clean up
rm -f "$AUDIO_FILE"