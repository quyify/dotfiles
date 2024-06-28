#!/bin/bash

# Ensure fzf, ffmpeg, and imagemagick are installed
if ! command -v fzf &>/dev/null || ! command -v ffmpeg &>/dev/null || ! command -v convert &>/dev/null; then
	echo "fzf, ffmpeg, and imagemagick must be installed. Please install them using Homebrew."
	exit 1
fi

# Ensure gifsicle is installed
if ! command -v gifsicle &>/dev/null; then
	echo "gifsicle must be installed. Please install it using Homebrew."
	exit 1
fi

# Step 1: Use fzf to select a file
selected_file=$(fzf --prompt="Select a video file to convert: ")

# Check if a file was selected
if [ -z "$selected_file" ]; then
	echo "No file selected. Exiting."
	exit 1
fi

# Get the base name of the selected file (without extension)
base_name=$(basename "$selected_file" | sed 's/\.[^.]*$//')

# Create a temporary directory for the frames
temp_dir=$(mktemp -d)

# Step 2: Use ffmpeg to turn the selected file into a series of frames
# Reduce frame rate to 10 fps and resize to 640x480
ffmpeg -i "$selected_file" -vf "fps=10,scale=640:-1" "$temp_dir/${base_name}_frame_%04d.png"

# Step 3: Convert the frames into an animated GIF
output_gif="${base_name}.gif"
convert -delay 10 -loop 0 "$temp_dir/${base_name}_frame_*.png" "$output_gif"

# Optimize the GIF using gifsicle
gifsicle -O3 "$output_gif" -o "$output_gif"

# Clean up the temporary directory
rm -r "$temp_dir"

echo "Animated GIF created: $output_gif"
