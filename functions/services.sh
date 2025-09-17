#!/bin/bash

kill_procs(){
    sudo pkill antivirus.sh
    sudo pkill backup_home.sh
    sudo pkill clamav
    sudo pkill clamd
    sudo pkill clamdscan
    sudo pkill clamscan
    sudo systemctl disable --now clamav-daemon.service
    sudo systemctl disable --now clamav-daemon.socket
}

update_anaicy() {
    if [ "$1" = "start" ]; then
        sudo systemctl enable --now ananicy-cpp
    elif [ "$1" = "stop" ]; then
        sudo systemctl disable --now ananicy-cpp
    fi
}

restart_lact() {
    sudo systemctl restart lact-daemon &
}

update_coolercontrol() {
    if [ "$1" = "start" ]; then
        sudo systemctl start coolercontrold
    elif [ "$1" = "stop" ]; then
        sudo systemctl stop coolercontrold
    fi 
}
