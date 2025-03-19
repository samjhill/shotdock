import cv2
import numpy as np
import os
from glob import glob

# Paths
input_folder = "/path/to/video/frames"
mask_output = "/path/to/mask.png"

# Create an accumulator image to track stationary spots
first_frame = None
accumulator = None

# Process each frame
for frame_path in sorted(glob(f"{input_folder}/*.jpg")):
    frame = cv2.imread(frame_path, cv2.IMREAD_GRAYSCALE)

    if first_frame is None:
        first_frame = frame.copy()
        accumulator = np.zeros_like(frame, dtype=np.float32)

    # Detect differences between current frame and the first frame
    diff = cv2.absdiff(first_frame, frame)
    _, threshold = cv2.threshold(diff, 30, 255, cv2.THRESH_BINARY)

    # Accumulate suspected dust specks
    accumulator += threshold

# Threshold accumulator to isolate persistent spots
_, mask = cv2.threshold(accumulator, 200, 255, cv2.THRESH_BINARY)

# Save the mask for ffmpeg
cv2.imwrite(mask_output, mask)
print(f"Mask saved to: {mask_output}")
