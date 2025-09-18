#!/bin/bash

# Includes
source "/etc/gameflux/functions/scx.sh"
source "/etc/gameflux/functions/renice.sh"
source "/etc/gameflux/functions/services.sh"
source "/etc/gameflux/functions/system.sh"

# Setup config and flag files
echo "false" > "/etc/gameflux/flags/status.txt"
current_state="normal"
get_sleep_values

# Reset log files
> "/etc/gameflux/flags/pid.txt"
> "/etc/gameflux/flags/downgrade-pid.txt"
> "/etc/gameflux/logs/pid-log.txt"

# Main mode switching function
# Params: gaming | general
update_mode() {
    echo "Updating to mode $1"
    # Start gaming mode
    if [ "$1" = "gaming" ]; then
        update_anaicy stop # Stop any instances of anaicy service
        update_scx start # Start any given scheduler
    # Reset to non-gaming mode
    elif [ "$1" = "general" ]; then
        update_scx stop # Stop any schedulers we launched
        update_anaicy start # Reset anaicy to default status if needed
        update_renice reset # Reset renice values of background services
        clear_ram_buffer # Clear ram buffer to free up space
    fi 
}

# Main loop to check for running games
while true; do
    if grep -q "true" "/etc/gameflux/flags/status.txt"; then
        # Game is running
        if [ "$current_state" != "gamemode" ]; then
            # The game jsut launched
            current_state="gamemode"
            update_mode gaming
        fi
        check_update_renice # Update renice values of programs
    else
        # Game is not running
        if [ "$current_state" != "normal" ]; then
            # The game was just stopped
            current_state="normal"
            update_mode general
        fi
    fi
    # Sleep time... Zzzzzz
    echo "Waiting $loop_time seconds"
    sleep "$loop_time"
done
