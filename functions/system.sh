#!/bin/bash

check_ram() {
    echo 3 | sudo tee /proc/sys/vm/drop_caches
}

reset_mouse() {
    for usb in /sys/bus/usb/devices/*/; do
        if [ -f "$usb/product" ] && grep -qi "Wireless" "$usb/product"; then
            echo "Resetting: $(cat "$usb/product") at $usb"
            echo 0 > "$usb/authorized" 2>/dev/null
            echo 1 > "$usb/authorized" 2>/dev/null
        fi
    done
}

update_power() {
    if [ "$1" = "gaming" ]; then
        sudo cpupower frequency-set --governor performance
        sudo cpupower frequency-set --max 5400000
        sudo cpupower frequency-set --min 4700000
    elif [ "$1" = "general" ]; then
        sudo cpupower frequency-set --governor schedutil
        sudo cpupower frequency-set --max 5200000
        sudo cpupower frequency-set --min 2990000
    fi
}