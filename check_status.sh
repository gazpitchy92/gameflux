#!/bin/bash

# Functions
SCRIPT_DIR="/home/gareth/scripts/gamemode"
source "$SCRIPT_DIR/functions/scx.sh"
source "$SCRIPT_DIR/functions/renice.sh"
source "$SCRIPT_DIR/functions/services.sh"
source "$SCRIPT_DIR/functions/system.sh"

update_mode() {
    echo "update_mode $1"
    reset_mouse
    if [ "$1" = "gaming" ]; then
        kill_procs
        update_coolercontrol stop
        update_anaicy stop
        update_power gaming
        update_scx start
        restart_lact
    elif [ "$1" = "general" ]; then
        update_coolercontrol start
        update_power general
        update_scx stop
        update_anaicy start
        update_renice reset
        check_ram
    fi 
}

# Setup new boot logs
echo "false" > "$SCRIPT_DIR/flags/status.txt"
echo "true" > "$SCRIPT_DIR/flags/vrr.txt"
> "$SCRIPT_DIR/flags/pid.txt"
> "$SCRIPT_DIR/flags/downgrade-pid.txt"
> "$SCRIPT_DIR/logs/pid-log.txt"

# Setup vars
current_state="normal"
get_sleep_values

# Start main loop
while true; do
    if grep -q "true" "$SCRIPT_DIR/flags/status.txt"; then
        if [ "$current_state" != "gamemode" ]; then
            # Gamemode started
            current_state="gamemode"
            update_mode gaming
        fi
        check_update_renice
    else
        if [ "$current_state" != "normal" ]; then
            # Gamemode stopped
            current_state="normal"
            update_mode general
        fi
    fi
    echo "Waiting $loop_time seconds"
    sleep "$loop_time"
done
