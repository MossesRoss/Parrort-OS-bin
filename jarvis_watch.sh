#!/bin/bash

# ==========================================
# PARROT OS: EXECUTION FAILURE TRIAGE
# ==========================================

if [ -z "$1" ]; then
    echo "Usage: jarvis_watch <command>"
    exit 1
fi

COMMAND_NAME="$1"

"$@"
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    # Success protocol (Queued normally)
    ~/.local/bin/jarvis_say "Execution of $COMMAND_NAME is complete Mr Mosas. Zero errors."
else
    # Failure protocol (Priority override to alert user immediately)
    ~/.local/bin/jarvis_say --critical "Pardon the interruption Mr Mosas. The $COMMAND_NAME process encountered a fatal exception and exited with code $EXIT_CODE. Awaiting your triage."
fi

exit $EXIT_CODE