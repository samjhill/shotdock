STAGING="$HOME/Videos/staging/"

mkdir -p "$STAGING/color_corrected"
for file in "$STAGING"/*.MP4; do
    ffmpeg -i "$file" \
      -vf "eq=brightness=0.03:saturation=1.2:contrast=1.1" \
      -c:a copy "$STAGING/color_corrected/$(basename "$file")"
done