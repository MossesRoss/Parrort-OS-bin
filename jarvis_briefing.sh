#!/bin/bash

# ==========================================
# JARVIS: EXECUTIVE MORNING BRIEFING
# ==========================================

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

speak() {
    pkill -f piper 2>/dev/null
    pkill -f aplay 2>/dev/null
    echo "$1" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_raw 2>/dev/null | aplay -r 22050 -f S16_LE -t raw -q
}

# 1. TIME & STATE ENFORCEMENT
# Check if it is before 12:00 PM
HOUR=$(date +%H)
if [ "$HOUR" -ge 16 ]; then
    exit 0 # It is past noon. Abort silently.
fi

# Check if the briefing has already run today
DATE_FILE="$HOME/.local/share/jarvis_morning_date"
TODAY=$(date +%F)

if [ -f "$DATE_FILE" ]; then
    LAST_RUN=$(cat "$DATE_FILE")
    if [ "$LAST_RUN" == "$TODAY" ]; then
        exit 0 # Already ran today. Abort silently.
    fi
fi

# Update the state file to mark today as executed
mkdir -p "$HOME/.local/share"
echo "$TODAY" > "$DATE_FILE"


# 2. TELEMETRY & AI SYNTHESIS (Python Native)
# We use Python to handle JSON, XML, and REST requests securely.
BRIEFING_TEXT=$(python3 << 'EOF'
import urllib.request
import urllib.parse
import json
import xml.etree.ElementTree as ET
import os

# ==========================================
# INSERT YOUR GEMINI API KEY HERE
# ==========================================
GEMINI_API_KEY = "YOUR_API_KEY_HERE"

def get_weather():
    try:
        # Fetching precise localized weather data
        location = urllib.parse.quote("Eachanari, Coimbatore - 641 021")
        req = urllib.request.Request(f"https://wttr.in/{location}?format=j1", headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            current = data['current_condition'][0]
            forecast = data['weather'][0]
            return f"Temp: {current['temp_C']}C, Condition: {current['weatherDesc'][0]['value']}. Today High/Low: {forecast['maxtempC']}C/{forecast['mintempC']}C."
    except Exception:
        return "Weather telemetry offline."

def get_news():
    try:
        # Fetching top breaking news for India
        req = urllib.request.Request("https://news.google.com/rss?hl=en-IN&gl=IN&ceid=IN:en", headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            root = ET.fromstring(response.read())
            # Extract top 3 headlines
            titles = [item.find('title').text for item in root.findall('.//item')[:3]]
            return " | ".join(titles)
    except Exception:
        return "News telemetry offline."

def synthesize_briefing(weather, news):
    prompt = f"""
    You are Jarvis, a ruthless, high-velocity AI assistant to CTO Mosses Ross. 
    It is morning. Generate a spoken morning briefing using this raw data. 
    Keep it energetic, highly concise, and under 80 words. Address him as Mr. Mosas. 
    Do NOT use asterisks, markdown, or emojis as this will be read by a Text-to-Speech engine. Spell out numbers simply.
    
    Raw Weather: {weather}
    Raw News: {news}
    """
    
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={GEMINI_API_KEY}"
    payload = json.dumps({"contents": [{"parts": [{"text": prompt}]}]}).encode('utf-8')
    headers = {'Content-Type': 'application/json'}
    
    try:
        req = urllib.request.Request(url, data=payload, headers=headers, method='POST')
        with urllib.request.urlopen(req) as response:
            res_data = json.loads(response.read().decode())
            # Extracting the text from Gemini's JSON structure
            return res_data['candidates'][0]['content']['parts'][0]['text'].strip()
    except Exception as e:
        return "Good morning Mr. Mosas. Telemetry generation failed, but systems are online."

weather_data = get_weather()
news_data = get_news()
print(synthesize_briefing(weather_data, news_data))
EOF
)

# 3. TTS EXECUTION
speak "$BRIEFING_TEXT"
