#!/bin/bash

get_settings_values() {
    while IFS=, read -r key value || [ -n "$key" ]; do
        key=${key//$'\r'/}
        value=${value//$'\r'/}
        value=$(echo "$value" | xargs)
        declare -g "${key}=$value"
        echo "${key}=$value" >> "$service_logs"
    done < /etc/gameflux/settings/general.txt
}

log_gameflux_settings() {
    echo "fsr4: $fsr4_set" >> $game_logs
    echo "rdna3: $rdna3_set" >> $game_logs
    echo "fsync: $fsync_set" >> $game_logs
    echo "scx: $scx_set" >> $game_logs
    echo "wayland: $wayland_set" >> $game_logs
    echo "other args: ${args[*]}" >> $game_logs
}

setup_runner_files() {
    scx_file="/etc/gameflux/flags/scx.txt"
    renice_flag="/etc/gameflux/flags/pid.txt"
    game_logs="/etc/gameflux/logs/game.txt"
    [ -f "$scx_file" ] || echo "none" > "$scx_file"
    : > "$renice_flag"
}

setup_service_files() {
    current_state="normal"
    get_settings_values
    game_logs="/etc/gameflux/logs/game.txt"
    service_logs="/etc/gameflux/logs/service.txt"
    renice_logs="/etc/gameflux/logs/renice.txt"
    status_flag="/etc/gameflux/flags/status.txt"
    renice_flag="/etc/gameflux/flags/pid.txt"
    downgrade_flag="/etc/gameflux/flags/downgrade-pid.txt"
    mkdir -p "$(dirname "$game_logs")" "$(dirname "$status_flag")"
    echo "false" > "$status_flag"
    : > "$game_logs"
    : > "$service_logs"
    : > "$renice_logs"
    : > "$renice_flag"
    : > "$downgrade_flag"
}
