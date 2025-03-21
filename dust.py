import cv2
import sys
import numpy as np
from glob import glob

input_folder = sys.argv[1]  # "$FRAME_FOLDER"
mask_output = sys.argv[2]   # "$STAGING/$file-dust_mask.png"

first_frame = None
accumulator = None

image_paths = sorted(glob(f"{input_folder}/*.jpg"))
if not image_paths:
    print("❌ No image frames found. Check your input path.")
    exit(1)

for frame_path in image_paths:
    frame = cv2.imread(frame_path, cv2.IMREAD_GRAYSCALE)
    if frame is None:
        print(f"❌ Failed to read {frame_path}. Skipping...")
        continue

    if first_frame is None:
        first_frame = frame.copy()
        accumulator = np.zeros_like(frame, dtype=np.float32)

    # Use background subtraction (static changes)
    diff = cv2.absdiff(first_frame, frame)

    # Apply Gaussian blur to reduce large movement and focus on static particles
    blurred_diff = cv2.GaussianBlur(diff, (7, 7), 0)

    # Threshold to focus on small, subtle differences
    _, threshold = cv2.threshold(blurred_diff, 10, 255, cv2.THRESH_BINARY)

    # Accumulate the thresholded difference for all frames
    accumulator += threshold

# Apply a second threshold to fine-tune the mask
_, mask = cv2.threshold(accumulator, 200, 255, cv2.THRESH_BINARY)

# Morphological operations to clean up the mask and remove noise
kernel = np.ones((5, 5), np.uint8)
mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)  # Closing to connect particles
mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)   # Opening to remove noise

# Convert image to 8-bit unsigned integer format
if mask.dtype != np.uint8:
    mask = cv2.convertScaleAbs(mask)

# Confirm successful mask creation
if cv2.imwrite(mask_output, mask):
    print(f"✅ Dust mask created at {mask_output}")
else:
    print("❌ Failed to write dust mask. Check permissions.")
    exit(1)
