#!/bin/bash

# 1. Path to your TARDIS wallpapers
DIR="$HOME/.config/.Wallpapers/tardis-ints"
STATE_FILE="$HOME/.config/hypr/.tardis_index"

# 2. Get all images in an array
mapfile -t IMAGES < <(ls "$DIR"/*.png | sort)
COUNT=${#IMAGES[@]}

# 3. Read the last index, default to 0 if file doesn't exist
IFILE=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

# 4. If IFILE is greater than or equal to count (maybe you deleted a file), reset to 0
if [ "$IFILE" -ge "$COUNT" ]; then
    IFILE=0
fi

# 5. Select the image
IMAGE="${IMAGES[$IFILE]}"

# 6. Apply with swww
swww img "$IMAGE" --transition-type grow --transition-pos center --transition-duration 1

# 7. Calculate next index and save it
NEXT_INDEX=$(( (IFILE + 1) % COUNT ))
echo "$NEXT_INDEX" > "$STATE_FILE"
