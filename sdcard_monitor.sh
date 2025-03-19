#!/bin/bash

# Watch for SD card mounts
fswatch -0 /Volumes | while read -d "" event
do
    echo "sd card monitor: $event"
    if [[ "$event" == "/Volumes/Untitled" ]]; then
        /usr/local/bin/sdcard_import.sh
    fi
done
