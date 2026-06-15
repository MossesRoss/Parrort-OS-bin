#!/bin/bash

# ==========================================
# JARVIS: NAUKRI ALGORITHM REFRESHER (PLAYWRIGHT)
# ==========================================

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

# 1. JARVIS Audio Briefing
TEXT="Updating your telemetry in Naukri, sir. Please do not close the new browser window. Move it to a background workspace while I execute the payload."
echo "$TEXT" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_raw 2>/dev/null | aplay -r 22050 -f S16_LE -t raw -q &

# 2. Launch Chrome in Debug Mode (Background)
# This opens your specific Bot profile and exposes the 9222 port for Playwright
google-chrome --remote-debugging-port=9222 --user-data-dir="$HOME/jarvis_chrome" > /dev/null 2>&1 &

# Wait 4 seconds for Chrome's rendering engine to fully boot
sleep 4

# 3. The Automation Payload (Python injected directly into Bash)
python3 << 'EOF'
from playwright.sync_api import sync_playwright
import time

def execute_payload():
    with sync_playwright() as p:
        try:
            # Connect to the exact Chrome instance we just spawned via CDP
            browser = p.chromium.connect_over_cdp("http://127.0.0.1:9222")
            context = browser.contexts[0]
            
            # Open a fresh tab for the payload
            page = context.new_page()
            
            # Navigate directly to the profile endpoint
            page.goto("https://www.naukri.com/mnjuser/profile?id=&altresid")
            
            # The Bypass: Playwright surgically targets the hidden file input without needing explicit waits
            resume_path = "/home/moss/Downloads/Mosses- NetSuite Technical Consultant.pdf"
            page.set_input_files("//input[@type='file']", resume_path)
            
            # Wait 5 seconds to ensure the Naukri servers process the upload successfully
            time.sleep(5)
            
            print("[*] Naukri algorithm successfully manipulated.")
            
            # Close the automation tab so your browser doesn't clutter
            page.close()
            
        except Exception as e:
            print(f"[!] Automation failure: {e}")

execute_payload()
EOF

# 4. Completion Audio
TEXT2="Upload complete, Mr Mosas. The recruiter algorithm has been refreshed."
echo "$TEXT2" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_raw 2>/dev/null | aplay -r 22050 -f S16_LE -t raw -q