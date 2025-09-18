#!/bin/bash

install_optiscaler() {
    if [ "$fsr4_set" = true ]; then
        if [ ! -f "$game_folder/dxgi.dll" ]; then
            cp -r /etc/gameflux/OptiScaler/* "$game_folder/"
            if [ -f "$game_folder/dxgi.dll" ]; then
                echo "OptiScaler copied successfully" >> $game_logs
            else
                echo "OptiScaler copy failed" >> $game_logs
            fi
        else
            echo "OptiScaler already installed" >> $game_logs
        fi
    elif [ -f "$game_folder/dxgi.dll" ]; then
        for item in /etc/gameflux/OptiScaler/*; do
            name=$(basename "$item")
            echo "OptiScaler cleanup removing: $game_folder/$name" >> $game_logs
            rm -rf "$game_folder/$name"
        done
    fi
}

setup_optiscaler_ini() {
    if [ "$rdna3_set" = "true" ]; then
        # TO DO : Update .ini file with flags to enable rdna3
    else
        # TO DO : Update .ini file with flags to disable rdna3
    fi
}