#!/bin/bash

SCRIPT_DIR="/home/gareth/scripts/gamemode"
source "$SCRIPT_DIR/functions/update.sh"

status_file="$SCRIPT_DIR/flags/status.txt"
vrr_file="$SCRIPT_DIR/flags/vrr.txt"
previous_state=""

[ -f "$status_file" ] || echo "false" > "$status_file"
[ -f "$vrr_file" ] || echo "true" > "$vrr_file"

while true; do
    check_gamemode
    update_status "$current_state"
    if [[ "$current_state" != "$previous_state" ]]; then
        if [[ "$current_state" == "true" ]]; then
            start_gamemode
        else
            end_gamemode
        fi
        previous_state="$current_state"
    fi
    echo "Waiting 5s"
    sleep 5
done
