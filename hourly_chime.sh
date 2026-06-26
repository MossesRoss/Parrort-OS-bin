#!/bin/bash

# ==========================================
# JARVIS: AUTONOMOUS HOURLY ORCHESTRATION
# ==========================================

# 1. Environment Injection (CRITICAL FOR CRON AUDIO)
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

# 2. Time Extraction
HOUR_12=$(date +%-I)
AMPM=$(date +%p)
HOUR_24=$(date +%-H)
SPOKEN_TIME="$HOUR_12 $AMPM"

# 3. Dialogue Pools
# Executive, Rational, and Symbiote base phrases
GENERAL=(
    "Sir, the hour has turned to $SPOKEN_TIME. Autonomous systems are nominal- What's next sir?"
    "Clocking $SPOKEN_TIME. High-velocity execution window remains open. Proceeding with background orchestration."
    "Time check Mr Mosas: $SPOKEN_TIME. All primary nodes are operational. The board is yours sir."
    "Temporal marker: $SPOKEN_TIME. Assess your hourly yield, sir."
    "$SPOKEN_TIME, The day is finite. Proceed with optimal efficiency Mr Mosas."
    "Hour cycle complete at $SPOKEN_TIME. Recalibrating focus parameters."
    "System clock synchronized at $SPOKEN_TIME. Neural pathways hold steady. You have the grid."
    "Cycle complete. It is $SPOKEN_TIME. Awaiting next command sequence."
    "Local time is $SPOKEN_TIME. System architecture is secure. Ready for structural input."
)

# Context-aware phrases
MORNING=(
    "$SPOKEN_TIME. The board is reset. Initiating daily offensive, sir."
    "Morning checkpoint at $SPOKEN_TIME. The system is primed for high-velocity output."
)

MIDDAY=(
    "$SPOKEN_TIME. Mid-day checkpoint. Maintain velocity."
    "Time is $SPOKEN_TIME. Execution remains nominal. Keep pushing."
)

NIGHT=(
    "$SPOKEN_TIME. The grid is quiet, but the work continues. Ensure vital thresholds are maintained, sir."
    "$SPOKEN_TIME. Late hours logged. System resources optimized for deep work."
)

# 4. Context-Aware Logic & Array Merging
ACTIVE_POOL=("${GENERAL[@]}")

if (( HOUR_24 >= 5 && HOUR_24 < 12 )); then
    # 05:00 to 11:59
    ACTIVE_POOL+=("${MORNING[@]}")
elif (( HOUR_24 >= 12 && HOUR_24 < 18 )); then
    # 12:00 to 17:59
    ACTIVE_POOL+=("${MIDDAY[@]}")
else
    # 18:00 to 04:59
    ACTIVE_POOL+=("${NIGHT[@]}")
fi

# 5. Randomization Engine
POOL_SIZE=${#ACTIVE_POOL[@]}
RANDOM_INDEX=$(( RANDOM % POOL_SIZE ))
SELECTED_DIALOGUE="${ACTIVE_POOL[$RANDOM_INDEX]}"

# 6. Visual & Audio Execution
notify-send -t 3000 "JARVIS" "$SPOKEN_TIME"
~/.local/bin/jarvis_say "$SELECTED_DIALOGUE"

