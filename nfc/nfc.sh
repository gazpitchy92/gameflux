#!/usr/bin/env fish

#sleep 15
pkill -f nfc_app.py

while true
    python /home/gareth/scripts/nfc/nfc_app.py
    echo "nfc_app.py crashed or exited, restarting in 5s..."
    sleep 5
end
