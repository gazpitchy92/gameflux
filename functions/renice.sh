#!/bin/bash

get_steam_pid() {
    [[ ! -f /etc/gameflux/settings/renice_upgrade.txt ]] && return
    while IFS=, read -r prog match; do
        pgrep_opt="-f"
        [[ "$match" == "-x" ]] && pgrep_opt="-x"
        for pid in $(pgrep "$pgrep_opt" "$prog"); do
            grep -Fxq "$pid" $renice_flag || echo "$pid" >> $renice_flag
        done
    done < /etc/gameflux/settings/renice_upgrade.txt
}

check_update_renice() {
    if [ "$renice_updgrade_programs" = true ]; then
        if [ "$(find $renice_logs -mmin +$renice_refresh_time_min 2>/dev/null)" ]; then
            update_renice update
        else
            echo "Renice on cooldown..."
        fi
    fi
}

update_renice() {
    if [ "$1" = "update" ]; then
        # Refresh logs
        echo "START RENICE LOGS AT $(date '+%Y-%m-%d %H:%M:%S')" > $renice_logs
        # Downgrade any background programs
        downgrade_programs_renice
        # Upgrade game related PID
        get_steam_pid
        if [ -f $renice_flag ]; then
            while read -r PID; do
                if [[ $PID =~ ^[0-9]+$ ]]; then
                    if kill -0 "$PID" 2>/dev/null; then
                        current_nice=$(ps -o nice= -p "$PID" | tr -d ' ')
                        if [[ -n "$current_nice" && "$current_nice" != "-" && "$current_nice" =~ [0-9] ]]; then
                            if [ "$current_nice" != "$renice_upgrade_value" ]; then
                                sudo renice -n $renice_upgrade_value -p "$PID" && \
                                echo -e "UPGRADE PID $PID nice changed to $renice_upgrade_value, updated" >> $renice_logs
                            else
                                echo -e "UPGRADE PID $PID nice is already $renice_upgrade_value, no change" >> $renice_logs
                            fi
                        else
                            echo -e "UPGRADE PID $PID invalid nice value, skipping" >> $renice_logs
                            sed -i "/^${PID}$/d" $renice_flag
                        fi
                    else
                        echo -e "UPGRADE PID $PID no longer running, skipping" >> $renice_logs
                        sed -i "/^${PID}$/d" $renice_flag
                    fi
                fi
                sleep "$renice_sleep_time_sec"
            done < $renice_flag
        fi
        echo "FINISH LOGS AT $(date '+%Y-%m-%d %H:%M:%S')" >> $renice_logs
    elif [ "$1" = "reset" ]; then
        # finish cleanup
        reset_programs_renice
        > $renice_flag
        > $downgrade_flag
    fi
}

downgrade_programs_renice() {
    if [ "$renice_downgrade_programs" = true ]; then
        while IFS=, read -r prog niceval; do
            [[ -z "$prog" ]] && continue
            pid=$(pgrep -x "$prog" | head -n1)
            [[ -z "$pid" ]] && continue
            orig=$(ps -o ni= -p "$pid" | tr -d ' ')
            [[ ! "$orig" =~ ^-?[0-9]+$ ]] && orig=0
            grep -q "^$prog," $downgrade_flag || echo "$prog,$orig" >> $downgrade_flag
            for pid in $(pgrep -x "$prog"); do
                sleep "$renice_sleep_time_sec"
                current=$(ps -o ni= -p "$pid" | tr -d ' ')
                if [[ "$current" == "$niceval" ]]; then
                    echo -e "DOWNGRADE PID $pid is already nice $niceval, skipping" >> $renice_logs
                    continue
                fi
                echo -e "DOWNGRADE PID $pid to nice $niceval" >> $renice_logs
                sudo renice -n "$niceval" -p "$pid"
            done
        done < /etc/gameflux/settings/renice_downgrade.txt
    fi
}

reset_programs_renice() {
    if [ "$renice_downgrade_programs" = true ]; then
        [[ ! -f $downgrade_flag ]] && return
        while IFS=, read -r prog orig; do
            [[ "$orig" -gt 10 ]] && orig=0
            for pid in $(pgrep -x "$prog"); do
                echo -e "RESET PID $pid to nice $orig" >> $renice_logs
                sudo renice "$orig" -p "$pid"
            done
        done < $downgrade_flag
        > $downgrade_flag
        echo "ENDED AT $(date '+%Y-%m-%d %H:%M:%S')" >> $renice_logs
    fi 
}