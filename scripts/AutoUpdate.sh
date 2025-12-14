#!/bin/bash

sleep 300
LOGFILE="$HOME/AutoUpdate.log"
[ -f "$LOGFILE" ] && rm "$LOGFILE"

for attempt in {1..5}; do
    if ping -c1 -W2 google.com >/dev/null 2>&1; then
        echo "$(date): Connected to Internet. Running update." >> "$LOGFILE"
        sudo akshara update >> "$LOGFILE" 2>&1
        flatpak update -y >> "$LOG_FILE"
        exit 0
    fi

    echo "$(date): Attempt $attempt failed. Retrying in 10 seconds." >> "$LOGFILE"
    sleep 10
done

echo "$(date): No Internet connection after 5 attempts. Exiting." >> "$LOGFILE"
exit 1
