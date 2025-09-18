#!/bin/bash

update_anaicy() {
    if [ "$1" = "start" ]; then
        # Start ananicy if it was previously enabled
        if [ -f /mnt/projects/gameflux/flags/ananicy.txt ] && grep -q '^enabled$' /mnt/projects/gameflux/flags/ananicy.txt; then
            sudo systemctl start ananicy-cpp
        fi
    elif [ "$1" = "stop" ]; then
        # Log the users default ananicy service state
        if systemctl list-unit-files | grep -q '^ananicy-cpp.service'; then
            if systemctl is-enabled ananicy-cpp &>/dev/null; then
                echo "enabled" > /mnt/projects/gameflux/flags/ananicy.txt
            else
                echo "disabled" > /mnt/projects/gameflux/flags/ananicy.txt
            fi
        fi
        # Stop ananicy service
        sudo systemctl stop ananicy-cpp
    fi
}
