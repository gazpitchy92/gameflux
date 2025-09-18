#!/bin/bash

clear_ram_buffer() {
    echo 3 | sudo tee /proc/sys/vm/drop_caches
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