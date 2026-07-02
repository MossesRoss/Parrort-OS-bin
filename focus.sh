#!/bin/bash

# ==========================================
# PARROT OS: DEEP WORK / ISOLATION PROTOCOL
# ==========================================

# --- CONCURRENCY LOCK ---
if pgrep -f "focus_hud.py" > /dev/null; then
    echo "[-] Protocol is already active. Override denied."
    exit 1
fi

MINUTES=${1:-90}
# Set your ruthless baseline. What is one hour of your deep, undistracted output worth?
HOURLY_RATE=500 

DISTRACTIONS=("discord" "telegram-desktop" "slack" "skype" "whatsapp" "youtube")

echo "[*] Neutralizing distraction vectors..."
for app in "${DISTRACTIONS[@]}"; do
    killall -9 "$app" 2>/dev/null
done

MANDATE="Operating in air-gapped stealth. Maximum compute is now routed to your foreground objectives."

notify-send -u critical "DEEP WORK ENGAGED" "Comms severed. Isolation timer set for $MINUTES minutes."

# --- ASYNCHRONOUS SYSTEM BRIEFING ---
# The trailing '&' forces this to run in the background so the HUD launches instantly.
nohup ~/.local/bin/jarvis_say "Focus protocol engaged. External comms are severed and distraction nodes are neutralized. $MANDATE You have $MINUTES minutes of absolute isolation. Let's build." >/dev/null 2>&1 &

echo "[*] Deep work protocol active for $MINUTES minutes. Launching HUD..."

# ==========================================
# PYTHON TKINTER HUD (COGNITIVE ENGINEERING)
# ==========================================
cat << 'EOF' > /tmp/focus_hud.py
import tkinter as tk
import sys
import time
import math
import os

if len(sys.argv) < 3:
    sys.exit(1)

total_minutes = int(sys.argv[1])
hourly_rate = float(sys.argv[2])

total_seconds = total_minutes * 60
start_time = time.time()
end_time = start_time + total_seconds

root = tk.Tk()
root.overrideredirect(True)
root.attributes('-topmost', True)
# Expanded height to 180 to give the data room to breathe
root.geometry("380x180+20+20") 
root.configure(bg='#050505')

canvas = tk.Canvas(root, width=380, height=180, bg='#050505', highlightthickness=0, cursor="fleur")
canvas.pack()

# --- PREMIUM TYPOGRAPHY ---
# Swap to "JetBrains Mono" or "Fira Code" if installed for maximum aesthetic.
UI_FONT = "DejaVu Sans Mono" 

# --- COGNITIVE ANCHORS ---
base_x, base_y = 190, 65

# 1. Autonomic Breathing Ring
ring = canvas.create_oval(base_x-80, base_y-40, base_x+80, base_y+40, outline="#005f73", width=1, dash=(2, 4))

# 2. Timer (Central Focus)
timer_text = canvas.create_text(base_x, base_y, text="00:00:00", font=(UI_FONT, 34, "bold"), fill="#005f73")

# 3. Value Accumulator - Pushed down by 55px to completely clear the breathing ring
equity_text = canvas.create_text(base_x, base_y + 55, text="$ 0.00", font=(UI_FONT, 14, "bold"), fill="#707070")

# 4. The "One Brick" Ledger 
brick_size = 8
brick_spacing = 4
total_bricks = max(1, total_minutes // 5)
bricks = []
start_brick_x = base_x - (((brick_size + brick_spacing) * total_bricks) // 2)

for i in range(total_bricks):
    x = start_brick_x + i * (brick_size + brick_spacing)
    y = 150 # Shifted down to respect the new spatial hierarchy
    # Contrast increased from #333333 to #666666 for better peripheral visibility
    b = canvas.create_rectangle(x, y, x + brick_size, y + brick_size, outline="#666666", fill="")
    bricks.append(b)

# --- DRAGGABILITY ---
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

canvas.bind("<ButtonPress-1>", start_move)
canvas.bind("<ButtonRelease-1>", stop_move)
canvas.bind("<B1-Motion>", do_move)

jarvis_path = os.path.expanduser("~/.local/bin/jarvis_say")
milestone_30_triggered = False
milestone_10_triggered = False

def update_ui():
    global milestone_30_triggered, milestone_10_triggered
    
    current_time = time.time()
    remaining = end_time - current_time
    elapsed = current_time - start_time
    
    if remaining <= 0:
        root.destroy()
        return

    # --- VOICE MILESTONES ---
    if remaining <= 1800 and not milestone_30_triggered:
        os.system(f'nohup {jarvis_path} "30 minutes remaining. Maintain trajectory." >/dev/null 2>&1 &')
        milestone_30_triggered = True
    elif remaining <= 600 and not milestone_10_triggered:
        os.system(f'nohup {jarvis_path} "10 minutes remaining. Execute the final sprint. Asset generation is peaking." >/dev/null 2>&1 &')
        milestone_10_triggered = True

    # --- CHROMATIC FLOW SHIFTING ---
    ratio = remaining / total_seconds
    if ratio > 0.5:
        color = "#005f73"  # Deep Cyan
    elif ratio > 0.15:
        color = "#e0e0e0"  # Crisp White
    else:
        color = "#ca6702"  # Amber

    # --- AUTONOMIC ENTRAINMENT (Breathing Ring) ---
    pulse = math.sin(current_time * (2 * math.pi / 11.0)) 
    r_width = 85 + (pulse * 10)
    r_height = 40 + (pulse * 5)
    canvas.coords(ring, base_x - r_width, base_y - r_height, base_x + r_width, base_y + r_height)
    canvas.itemconfig(ring, outline=color)

    # --- TIMER & VALUE UPDATE ---
    r_int = int(remaining)
    mins, secs = divmod(r_int, 60)
    hours, mins = divmod(mins, 60)
    canvas.itemconfig(timer_text, text=f"{hours:02d}:{mins:02d}:{secs:02d}", fill=color)

    equity = (elapsed / 3600.0) * hourly_rate
    canvas.itemconfig(equity_text, text=f"EQ: $ {equity:0.2f}")

    # --- LEDGER UPDATE ---
    elapsed_minutes = elapsed / 60.0
    bricks_earned = int(elapsed_minutes // 5)
    
    for i in range(total_bricks):
        if i < bricks_earned:
            canvas.itemconfig(bricks[i], fill=color, outline=color)
        else:
            canvas.itemconfig(bricks[i], fill="", outline="#666666")

    root.after(50, update_ui)

update_ui()
root.mainloop()
EOF

python3 /tmp/focus_hud.py "$MINUTES" "$HOURLY_RATE"

rm -f /tmp/focus_hud.py

echo -e "\n[*] Protocol complete. Unlocking perimeter."
notify-send -u normal "DEEP WORK COMPLETE" "Focus block achieved. Assets generated."

nohup ~/.local/bin/jarvis_say "Time is up. The focus block is complete. Local perimeter is unlocked and network traffic is permitted. Exceptional execution today." >/dev/null 2>&1 &
exit 0