#!/bin/bash

# ==========================================
# PARROT OS: DEEP WORK / ISOLATION PROTOCOL
# ==========================================

MINUTES=${1:-90}

DISTRACTIONS=("discord" "telegram-desktop" "slack" "skype" "whatsapp")

echo "[*] Neutralizing distraction vectors..."
for app in "${DISTRACTIONS[@]}"; do
    killall -9 "$app" 2>/dev/null
done

MANDATE="Operating in air-gapped stealth. Maximum compute is now routed to your foreground objectives."

notify-send -u critical "DEEP WORK ENGAGED" "Comms severed. Isolation timer set for $MINUTES minutes."

# Voice synthesized output
~/.local/bin/jarvis_say "Focus protocol engaged Mr Mosses. External comms are severed and distraction nodes are neutralized. $MANDATE You have $MINUTES minutes of absolute isolation. Lets build."

echo "[*] Deep work protocol active for $MINUTES minutes. Launching HUD..."

# ==========================================
# PYTHON TKINTER HUD 
# ==========================================
cat << 'EOF' > /tmp/focus_hud.py
import tkinter as tk
import sys
import time
import os

if len(sys.argv) < 2:
    sys.exit(1)

total_seconds = int(sys.argv[1]) * 60
end_time = time.time() + total_seconds

root = tk.Tk()
root.overrideredirect(True)
root.attributes('-topmost', True)
root.geometry("+20+20")
root.configure(bg='black')

# Scaled up UI for peripheral visibility
label = tk.Label(root, text="", font=("Courier", 32, "bold"), fg="red", bg="black", cursor="fleur")
label.pack(padx=20, pady=10)

# Draggability logic
def start_move(event):
    root.x = event.x
    root.y = event.y

def stop_move(event):
    root.x = None
    root.y = None

def do_move(event):
    deltax = event.x - root.x
    deltay = event.y - root.y
    x = root.winfo_x() + deltax
    y = root.winfo_y() + deltay
    root.geometry(f"+{x}+{y}")

label.bind("<ButtonPress-1>", start_move)
label.bind("<ButtonRelease-1>", stop_move)
label.bind("<B1-Motion>", do_move)

jarvis_path = os.path.expanduser("~/.local/bin/jarvis_say")

def update_timer():
    remaining = int(end_time - time.time())
    if remaining <= 0:
        root.destroy()
    else:
        # Milestone Notifications (Executed asynchronously)
        if remaining == 1800:
            os.system(f'nohup {jarvis_path} "30 minutes remaining. Maintain trajectory." >/dev/null 2>&1 &')
        elif remaining == 600:
            os.system(f'nohup {jarvis_path} "10 minutes remaining. Execute the final sprint." >/dev/null 2>&1 &')

        mins, secs = divmod(remaining, 60)
        hours, mins = divmod(mins, 60)
        label.config(text=f"{hours:02d}:{mins:02d}:{secs:02d}")
        root.after(1000, update_timer)

update_timer()
root.mainloop()
EOF

# Execute the HUD.
python3 /tmp/focus_hud.py "$MINUTES"

# Cleanup
rm -f /tmp/focus_hud.py

echo -e "\n[*] Protocol complete. Unlocking perimeter."
notify-send -u normal "DEEP WORK COMPLETE" "Focus block achieved."

~/.local/bin/jarvis_say "Time is up Mr Mosses. The focus block is complete. Local perimeter is unlocked and network traffic is permitted. Excellent execution today."
exit 0