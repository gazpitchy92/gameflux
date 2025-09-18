#!/bin/bash

get_sleep_values() {
    while IFS=, read -r key value || [ -n "$key" ]; do
        key=${key//$'\r'/}
        value=${value//$'\r'/}
        value=$(echo "$value" | xargs)
        declare -g "${key}=$value"
        echo "${key}=$value"
    done < /home/gareth/scripts/gamemode/settings/wait_times.txt
}