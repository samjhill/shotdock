STAGING="$HOME/Videos/staging/"

for file in "$STAGING/color_corrected/"*.MP4; do
    echo "stabilizing $file"
    ffmpeg -i "$file" -vf vidstabdetect=shakiness=10:accuracy=15 -f null -
    ffmpeg -i "$file" -vf removegrain=10,eq=brightness=0.02:saturation=1.1,vidstabtransform=smoothing=30:zoom=0.9 $STAGING/stabilized/$(basename "$file")
done
