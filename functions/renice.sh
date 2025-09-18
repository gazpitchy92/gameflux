#!/bin/bash

get_steam_pid() {
    [[ ! -f /etc/gameflux/settings/renice_upgrade.txt ]] && return
    while IFS=, read -r prog match; do
        pgrep_opt="-f"
        [[ "$match" == "-x" ]] && pgrep_opt="-x"
        for pid in $(pgrep "$pgrep_opt" "$prog"); do
            grep -Fxq "$pid" /etc/gameflux/flags/pid.txt || echo "$pid" >> /etc/gameflux/flags/pid.txt
        done
    done < /etc/gameflux/settings/renice_upgrade.txt
}

check_update_renice() {
    if [ "$(find /etc/gameflux/logs/pid-log.txt -mmin +$renice_refresh_time 2>/dev/null)" ]; then
        update_renice update
    else
        echo "Renice on cooldown..."
    fi
}

update_renice() {
    if [ "$1" = "update" ]; then
        # Refresh logs
        echo "START LOGS AT $(date '+%Y-%m-%d %H:%M:%S')" > /etc/gameflux/logs/pid-log.txt
        # Downgrade any background programs
        downgrade_programs_renice
        # Upgrade game related PID
        get_steam_pid
        if [ -f /etc/gameflux/flags/pid.txt ]; then
            while read -r PID; do
                if [[ $PID =~ ^[0-9]+$ ]]; then
                    if kill -0 "$PID" 2>/dev/null; then
                        current_nice=$(ps -o nice= -p "$PID" | tr -d ' ')
                        if [[ -n "$current_nice" && "$current_nice" != "-" && "$current_nice" =~ [0-9] ]]; then
                            if [ "$current_nice" != "-20" ]; then
                                sudo renice -n -20 -p "$PID" && \
                                echo -e "UPGRADE PID $PID nice changed to -20, updated" >> /etc/gameflux/logs/pid-log.txt
                            else
                                echo -e "UPGRADE PID $PID nice is already -20, no change" >> /etc/gameflux/logs/pid-log.txt
                            fi
                        else
                            echo -e "UPGRADE PID $PID invalid nice value, skipping" >> /etc/gameflux/logs/pid-log.txt
                            sed -i "/^${PID}$/d" /etc/gameflux/flags/pid.txt
                        fi
                    else
                        echo -e "UPGRADE PID $PID no longer running, skipping" >> /etc/gameflux/logs/pid-log.txt
                        sed -i "/^${PID}$/d" /etc/gameflux/flags/pid.txt
                    fi
                fi
                sleep "$renice_sleep_time"
            done < /etc/gameflux/flags/pid.txt
        fi
        echo "FINISH LOGS AT $(date '+%Y-%m-%d %H:%M:%S')" >> /etc/gameflux/logs/pid-log.txt
    elif [ "$1" = "reset" ]; then
        # finish cleanup
        reset_programs_renice
        pkill -9 -f rungame
        > /etc/gameflux/flags/pid.txt
        > /etc/gameflux/flags/downgrade-pid.txt
    fi
}

downgrade_programs_renice() {
    while IFS=, read -r prog niceval; do
        [[ -z "$prog" ]] && continue
        pid=$(pgrep -x "$prog" | head -n1)
        [[ -z "$pid" ]] && continue
        orig=$(ps -o ni= -p "$pid" | tr -d ' ')
        [[ ! "$orig" =~ ^-?[0-9]+$ ]] && orig=0
        grep -q "^$prog," /etc/gameflux/flags/downgrade-pid.txt || echo "$prog,$orig" >> /etc/gameflux/flags/downgrade-pid.txt
        for pid in $(pgrep -x "$prog"); do
            sleep "$renice_sleep_time"
            current=$(ps -o ni= -p "$pid" | tr -d ' ')
            if [[ "$current" == "$niceval" ]]; then
                echo -e "DOWNGRADE PID $pid is already nice $niceval, skipping" >> /etc/gameflux/logs/pid-log.txt
                continue
            fi
            echo -e "DOWNGRADE PID $pid to nice $niceval" >> /etc/gameflux/logs/pid-log.txt
            sudo renice -n "$niceval" -p "$pid"
        done
    done < /etc/gameflux/settings/renice_downgrade.txt
}

reset_programs_renice() {
    [[ ! -f /etc/gameflux/flags/downgrade-pid.txt ]] && return
    while IFS=, read -r prog orig; do
        [[ "$orig" -gt 10 ]] && orig=0
        for pid in $(pgrep -x "$prog"); do
            echo -e "RESET PID $pid to nice $orig" >> /etc/gameflux/logs/pid-log.txt
            sudo renice "$orig" -p "$pid"
        done
    done < /etc/gameflux/flags/downgrade-pid.txt
    > /etc/gameflux/flags/downgrade-pid.txt
    echo "ENDED AT $(date '+%Y-%m-%d %H:%M:%S')" >> /etc/gameflux/logs/pid-log.txt
}