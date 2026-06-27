#!/bin/bash

# ==============================================================================
# STARK INDUSTRIES: BINARY TELEMETRY TRACKER & ENFORCER
# ==============================================================================

DB_PATH="$HOME/.local/share/jarvis_tracker.db"

# Standard ANSI formatting for the HUD
CYAN='\033[96m'
GREEN='\033[92m'
RED='\033[91m'
YELLOW='\033[93m'
BOLD='\033[1m'
RESET='\033[0m'

# 1. Initialize SQLite Database
mkdir -p "$(dirname "$DB_PATH")"
sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS daily_telemetry (
    date TEXT PRIMARY KEY,
    outreach INTEGER,
    pow INTEGER,
    deep_work INTEGER,
    sleep INTEGER,
    exercise INTEGER,
    mvc INTEGER,
    is_maintenance INTEGER,
    total_score INTEGER
);"

TODAY=$(date +"%Y-%m-%d")

# 2. Central Audio Arbitrator
jarvis_speak() {
    local text="$1"
    if [ -x "$HOME/.local/bin/jarvis_say.sh" ]; then
        "$HOME/.local/bin/jarvis_say.sh" --critical "$text" >/dev/null 2>&1
    elif [ -x "$HOME/.local/bin/jarvis_say" ]; then
        "$HOME/.local/bin/jarvis_say" --critical "$text" >/dev/null 2>&1
    fi
}

# 3. Enforcer Mode (Runs via Cron)
if [[ "$1" == "--enforce" ]]; then
    # Check if we already logged telemetry today
    LOGGED=$(sqlite3 "$DB_PATH" "SELECT count(*) FROM daily_telemetry WHERE date='$TODAY';")
    if [ "$LOGGED" -eq 1 ]; then
        exit 0 # CEO has already executed. Stay silent.
    else
        # Sound the alarm and force a terminal overlay
        jarvis_speak "CEO override. Daily binary telemetry is missing. Execution required immediately."
        
        # Spawn a terminal window to force input (Parrot OS compatible)
        x-terminal-emulator -e "bash -c '$0; echo \"Saved. You may close this window.\"; sleep 3'" &
        exit 0
    fi
fi

# ==============================================================================
# INTERACTIVE HUD (Manual or Enforcer-Triggered)
# ==============================================================================

clear
echo -e "${CYAN}${BOLD}======================================================${RESET}"
echo -e "${CYAN}${BOLD}      JARVIS: BINARY EXECUTION MATRIX (${TODAY})      ${RESET}"
echo -e "${CYAN}${BOLD}======================================================${RESET}"
echo -e "Enter '1' for Completion, '0' for Failure."
echo -e "Enter 'm' to declare a Biological Maintenance Day."
echo -e "${CYAN}------------------------------------------------------${RESET}\n"

# Validate Input Function
get_input() {
    local prompt="$1"
    local var_name="$2"
    local val=""
    while true; do
        read -p "$(echo -e "${BOLD}${prompt}${RESET} ")" val
        if [[ "$val" == "1" || "$val" == "0" ]]; then
            eval "$var_name=$val"
            break
        elif [[ "${val,,}" == "m" || "${val,,}" == "maintenance" ]]; then
            eval "$var_name=\"m\""
            break
        else
            echo -e "${RED}Invalid input. 1, 0, or m only.${RESET}"
        fi
    done
}

# Prompt for Telemetry
get_input "[OFFENSE] Targeted Outreach (10 Pitches):" OUTREACH
if [[ "$OUTREACH" == "m" ]]; then
    echo -e "${YELLOW}[!] Maintenance Protocol Engaged. Offense metrics bypassed.${RESET}\n"
    IS_MAINT=1
    OUTREACH=1
    POW=1
    DEEP_WORK=1
else
    IS_MAINT=0
    get_input "[OFFENSE] Proof of Work (Content/Commit):" POW
    get_input "[OFFENSE] Deep Work (Two 90m blocks):" DEEP_WORK
fi

get_input "[DEFENSE] Neuro-Recovery (7+ hrs sleep):" SLEEP
get_input "[DEFENSE] Cortisol Flush (30m exertion):" EXERCISE
get_input "[STEALTH] MVC Execution (Zero unforced errors):" MVC

# 4. Calculate and Store
TOTAL_SCORE=$((OUTREACH + POW + DEEP_WORK + SLEEP + EXERCISE + MVC))

sqlite3 "$DB_PATH" "INSERT OR REPLACE INTO daily_telemetry 
(date, outreach, pow, deep_work, sleep, exercise, mvc, is_maintenance, total_score) 
VALUES ('$TODAY', $OUTREACH, $POW, $DEEP_WORK, $SLEEP, $EXERCISE, $MVC, $IS_MAINT, $TOTAL_SCORE);"

echo -e "\n${CYAN}------------------------------------------------------${RESET}"
echo -e "Telemetry locked. Day Score: ${BOLD}${TOTAL_SCORE}/6${RESET}"

# 5. Evaluate Rolling 7-Day Average
AVG_SCORE=$(sqlite3 "$DB_PATH" "SELECT ROUND(AVG(total_score), 2) FROM (SELECT total_score FROM daily_telemetry ORDER BY date DESC LIMIT 7);")

echo -e "7-Day Rolling Average: ${BOLD}${AVG_SCORE}/6${RESET}\n"

# Convert float to int for basic bash comparison
AVG_INT=$(echo "$AVG_SCORE" | awk '{print int($1+0.5)}')

if [ "$AVG_INT" -ge 5 ]; then
    echo -e "${GREEN}SYSTEM STATUS: OPTIMAL. The arc reactor is stable. Pipeline is expanding.${RESET}"
elif [ "$AVG_INT" -ge 3 ]; then
    echo -e "${YELLOW}SYSTEM STATUS: WARNING. Execution is drifting. Tighten the perimeter.${RESET}"
else
    echo -e "${RED}SYSTEM STATUS: CRITICAL. Burnout imminent or pipeline collapsing. Adjust immediately.${RESET}"
fi

echo -e "${CYAN}======================================================${RESET}"