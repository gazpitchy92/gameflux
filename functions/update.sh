#!/bin/bash

set_vrr() {
    if [[ "$1" == "true" ]]; then
        kscreen-doctor output.1.vrrpolicy.always
        kscreen-doctor output.2.vrrpolicy.always
    else
        kscreen-doctor output.1.vrrpolicy.never
        kscreen-doctor output.2.vrrpolicy.never
    fi
}

start_gamemode() {
    echo "Start Gamemode"
    notify-send "Gamemode Enabled" "Gamemode has been enabled"
    vrr_state=$(< "$vrr_file")
    set_vrr "$vrr_state"
}

end_gamemode() {
    echo "End Gamemode"
    notify-send "Gamemode Disabled" "Gamemode has been disabled"
    echo "true" > "$vrr_file"
    set_vrr false
}

update_status() {
    echo "$1" > "$status_file"
}

check_gamemode() {
    if gamemoded -s | grep -q "gamemode is active"; then
        current_state="true"
    else
        current_state="false"
    fi
}