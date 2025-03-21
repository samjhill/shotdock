#!/bin/bash

# Watch for SD card mounts
/opt/homebrew/bin/fswatch -o /Volumes/ | while read; do
    echo "sd card monitor: $event"
    # if [[ "$event" == "/Volumes/" ]]; then
        /usr/local/bin/sdcard_import.sh
    # fi
done
