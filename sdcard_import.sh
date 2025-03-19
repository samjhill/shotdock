#!/bin/bash

echo "sdcard_import started"

# Paths
TIMESTAMP=$(date +%s)
SOURCE="/Volumes/Untitled/PRIVATE/M4ROOT/CLIP/"
STAGING="$HOME/Videos/$TIMESTAMP/staging/"
DESTINATION="$HOME/Videos/Final/"
LOGFILE="$HOME/sdcard_import.log"

# Send macOS Notification
send_notification() {
    osascript -e "display notification \"$1\" with title \"Video Import\""
}

# Log and Notify
log_and_notify() {
    echo "$(date): $1" | tee -a "$LOGFILE"
    send_notification "$1"
}

log_and_notify "✅ SD card detected. Video import started."

# Calculate file size for progress estimation
TOTAL_SIZE=$(du -sh "$SOURCE" | cut -f1)
log_and_notify "🔎 Total size of files to copy: $TOTAL_SIZE"

# Copy files to staging (with deduplication)
START_TIME=$(date +%s)
mkdir -p "$STAGING"
rsync -avz --ignore-existing "$SOURCE" "$STAGING"


END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
log_and_notify "✅ Files copied successfully in $DURATION seconds."

# Dust Removal Step
log_and_notify "🧹 Detecting and removing dust spots..."
mkdir -p "$STAGING/frames"
mkdir -p "$STAGING/dust_fixed"

# Extract frames
for file in "$STAGING"/*.MP4; do
    FRAME_FOLDER="$STAGING/frames/$(basename "$file" .MP4)"
    mkdir -p "$FRAME_FOLDER"
    ffmpeg -i "$file" -vf "fps=1" "$FRAME_FOLDER/%04d.jpg"
    
    # Run Python dust detection
    python3 <<EOF
import cv2
import numpy as np
import os
from glob import glob

input_folder = "$FRAME_FOLDER"
mask_output = "$STAGING/dust_mask.png"

first_frame = None
accumulator = None

for frame_path in sorted(glob(f"{input_folder}/*.jpg")):
    frame = cv2.imread(frame_path, cv2.IMREAD_GRAYSCALE)
    if first_frame is None:
        first_frame = frame.copy()
        accumulator = np.zeros_like(frame, dtype=np.float32)

    diff = cv2.absdiff(first_frame, frame)
    _, threshold = cv2.threshold(diff, 30, 255, cv2.THRESH_BINARY)
    accumulator += threshold

_, mask = cv2.threshold(accumulator, 200, 255, cv2.THRESH_BINARY)
cv2.imwrite(mask_output, mask)
EOF

    # Apply mask to remove dust spots
    ffmpeg -i "$file" -i "$STAGING/dust_mask.png" \
        -vf "inpaint=radius=10:strength=1.0" \
        -c:a copy "$STAGING/dust_fixed/$(basename "$file")"
done

log_and_notify "🧼 Dust removal completed."

START_TIME=$(date +%s)
mkdir -p "$STAGING/color_corrected"
for file in "$STAGING"dust_fixed/*.MP4; do
    # Color Correction with Parallel
    mkdir -p "$STAGING/color_corrected"
    find "$STAGING"dust_fixed/ -maxdepth 1 -name "*.MP4" | parallel --bar -j "$(sysctl -n hw.ncpu)" \
        ffmpeg -i {} \
        -vf "eq=brightness=0.03:saturation=1.2:contrast=1.1" \
        -c:a copy "$STAGING/color_corrected/{/}"

    # Stabilization with Parallel
    # mkdir -p "$STAGING/stabilized"
    # find "$STAGING/color_corrected/" -maxdepth 1 -name "*.MP4" | parallel --bar -j "$(sysctl -n hw.ncpu)" \
    #     'ffmpeg -i {} -vf vidstabdetect=shakiness=10:accuracy=15 -f null - && \
    #     ffmpeg -i {} -vf removegrain=10,eq=brightness=0.02:saturation=1.1,vidstabtransform=smoothing=30:zoom=0.9 "$STAGING/stabilized/{/}"'

done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
log_and_notify "Color correction & stabiliation completed in $DURATION seconds."

# Thumbnail Generation
mkdir -p "$STAGING/thumbnails"
for file in "$STAGING/color_corrected/"*.MP4; do
    ffmpeg -i "$file" -ss 00:00:05 -vframes 1 "$STAGING/thumbnails/$(basename "$file" .MP4).jpg"
done

log_and_notify "🖼️ Thumbnails generated."

# File Size Summary
FINAL_SIZE=$(du -sh "$STAGING" | cut -f1)
log_and_notify "📏 Final size of imported files: $FINAL_SIZE"

log_and_notify "🎬 Video import process completed successfully!"
