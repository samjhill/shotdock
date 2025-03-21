#!/bin/bash

# Define the directory to monitor
MONITOR_DIR="/Volumes"

# Set the file pattern to watch for (video files)
WATCH_PATTERN="*.mp4|*.mov|*.avi|*.mkv"

# Use fswatch to monitor for new files in the directory
fswatch -o "$MONITOR_DIR" | while read event
do
    # Check if the event matches the video file pattern
    find /Volumes/ -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mkv" \) | while read file
    do
        echo "New video file detected: $file"
        # Add your video file handling logic here
    done
done
