STAGING="$HOME/Videos/1742395331/staging"

# Dust Removal Step
mkdir -p "$STAGING/frames"
mkdir -p "$STAGING/dust_fixed"

# Extract frames
for file in "$STAGING"/*.MP4; do
#     FRAME_FOLDER="$STAGING/frames/$(basename "$file" .MP4)"
#     mkdir -p "$FRAME_FOLDER"
#     ffmpeg -i "$file" -vf "fps=1" "$FRAME_FOLDER/%04d.jpg"
    
#     # Run Python dust detection
#     python3 -m dust $FRAME_FOLDER "$file-dust_mask.png"
      ffmpeg -i "$file" -vf "removelogo=$file-dust_mask.png" "$STAGING/dust_fixed/$(basename "$file")"
done

# Apply mask to remove dust spots
# find "$STAGING" -maxdepth 1 -name "*.MP4" | parallel --bar -j "$(sysctl -n hw.ncpu)" \
#         ffmpeg -i {} -vf "removelogo={}-dust_mask.png" "$STAGING/dust_fixed/{/}"

# log_and_notify "🧼 Dust removal completed."