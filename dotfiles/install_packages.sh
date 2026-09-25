#!/bin/bash

# Check if a file argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No file specified"
    echo "Usage: $0 <package-file>"
    exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found"
    exit 1
fi

# Read packages from file and install them
# - Remove empty lines
# - Remove comment lines (starting with #)
packages=$(grep -v '^[[:space:]]*#' "$1" | grep -v '^[[:space:]]*$')

if [ -z "$packages" ]; then
    echo "Error: No valid packages found in the file"
    exit 1
fi

echo "Installing packages:"
echo "$packages"
echo

# Install packages using pacman
sudo pacman -S --needed --noconfirm $packages

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo "All packages installed successfully"
else
    echo "Error: Package installation failed"
    exit 1
fi
