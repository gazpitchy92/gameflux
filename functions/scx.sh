#!/bin/bash

update_scx() {
    if [ "$1" = "start" ]; then 
        case "$(</home/gareth/scripts/gamemode/flags/scx.txt)" in
            lavd)
                kill_all_scx
                sudo scx_lavd --performance &
                ;;
            bpfland)
                kill_all_scx
                sudo scx_bpfland -m performance &
                ;;
            cosmos)
                kill_all_scx
                scx_cosmos -m performance -c 0 -p 0 -w &
                ;;
            rusty)
                kill_all_scx
                scx_rusty &
                ;;
            p2dq)
                kill_all_scx
                scx_p2dq --task-slice true -f --sched-mode performance &
                ;;
            flash)
                kill_all_scx
                scx_flash -m performance -w -C 0 &
                ;;
            none)
                kill_all_scx
                ;;
        esac
    elif [ "$1" = "stop" ]; then
        kill_all_scx
    fi
}

kill_all_scx() {
    for s in scx_bpfland scx_lavd scx_cosmos scx_rusty scx_p2dq scx_flash; do
        sudo pkill -f "$s"
        pids=$(pgrep -f "$s")
        [ -n "$pids" ] && sudo kill -9 $pids
    done
    echo "none" > /home/gareth/scripts/gamemode/flags/scx.txt
}