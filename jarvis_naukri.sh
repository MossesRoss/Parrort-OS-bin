#!/bin/bash

# ==========================================
# JARVIS: NAUKRI ALGORITHM REFRESHER (PLAYWRIGHT)
# ==========================================

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

# 1. JARVIS Audio Briefing (Queued)
jarvis_say "Updating your telemetry in Naukri, sir. Please do not close the new browser window. Move it to a background workspace while I execute the payload."

# 2. Launch Chrome in Debug Mode
if ! ss -tuln | grep -q ":9222"; then
    google-chrome --remote-debugging-port=9222 --user-data-dir="$HOME/jarvis_chrome" > /dev/null 2>&1 &
    sleep 4
fi

# 3. The Automation Payload
python3 << 'EOF'
from playwright.sync_api import sync_playwright
import time

def execute_payload():
    with sync_playwright() as p:
        try:
            browser = p.chromium.connect_over_cdp("http://127.0.0.1:9222")
            context = browser.contexts[0]
            
            page = context.new_page()
            page.goto("https://www.naukri.com/mnjuser/profile?id=&altresid")
            
            resume_path = "/home/moss/Downloads/Mosses- NetSuite Technical Consultant.pdf"
            page.set_input_files("//input[@type='file']", resume_path)
            
            time.sleep(5)
            print("[*] Naukri algorithm successfully manipulated.")
            page.close()
            
        except Exception as e:
            print(f"[!] Automation failure: {e}")

execute_payload()
EOF

# 4. Completion Audio
jarvis_say "Upload complete, Mr Mosas. The recruiter algorithm has been refreshed."