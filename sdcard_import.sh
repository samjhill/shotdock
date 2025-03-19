#!/bin/bash

echo "sdcard_import started"

# Paths
SOURCE="/Volumes/Untitled/PRIVATE/M4ROOT/CLIP/"
STAGING="$HOME/Videos/staging/"
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

# Confirm SD card is mounted
echo "sdcard_import: $SOURCE"
if [ ! -d "$SOURCE" ]; then
    log_and_notify "❌ SD card not detected. Aborting."
    exit 1
fi

log_and_notify "✅ SD card detected. Video import started."

# Calculate file size for progress estimation
TOTAL_SIZE=$(du -sh "$SOURCE" | cut -f1)
log_and_notify "🔎 Total size of files to copy: $TOTAL_SIZE"

# Copy files to staging (with deduplication)
START_TIME=$(date +%s)
rsync -av --ignore-existing "$SOURCE" "$STAGING"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
log_and_notify "✅ Files copied successfully in $DURATION seconds."

# Color correction with ffmpeg
START_TIME=$(date +%s)
mkdir -p "$STAGING/color_corrected"
for file in "$STAGING"/*.MP4; do
    ffmpeg -i "$file" \
      -vf "eq=brightness=0.03:saturation=1.2:contrast=1.1" \
      -c:a copy "$STAGING/color_corrected/$(basename "$file")"
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
log_and_notify "🎨 Color correction completed in $DURATION seconds."

# Thumbnail Generation
mkdir -p "$STAGING/thumbnails"
for file in "$STAGING/color_corrected/"*.MP4; do
    ffmpeg -i "$file" -ss 00:00:05 -vframes 1 "$STAGING/thumbnails/$(basename "$file" .MP4).jpg"
done

log_and_notify "🖼️ Thumbnails generated."

# Organize by date
START_TIME=$(date +%s)
find "$STAGING/color_corrected/" -type f -name "*.MP4" | while read file; do
    DATE=$(exiftool -d "%Y/%m/%d" -DateTimeOriginal "$file" | awk '{print $NF}')
    DEST="$DESTINATION/$DATE"
    mkdir -p "$DEST"
    mv "$file" "$DEST/"
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
log_and_notify "📂 Videos organized in $DESTINATION in $DURATION seconds."

# File Size Summary
FINAL_SIZE=$(du -sh "$DESTINATION" | cut -f1)
log_and_notify "📏 Final size of imported files: $FINAL_SIZE"

log_and_notify "🎬 Video import process completed successfully!"
