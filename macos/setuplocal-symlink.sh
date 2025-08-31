#!/bin/bash

# Alternative setup using symbolic links for real-time sync

# Usage: ./setuplocal-symlink.sh <track>

set -e  # Exit on any error

# === Same Python and tool setup as original script ===
# (Copy the first parts from setuplocal.sh)

TRACK=$1
if [ -z "$TRACK" ]; then
    echo "ERROR: Usage: $0 <track>"
    exit 1
fi


# Check if the lanedge directory exists locally
if [ ! -d "lanedge" ]; then
        echo "ERROR: Local lanedge directory not found at ./lanedge"
        echo "Please ensure you have the lanedge repository cloned in this directory."
        exit 1
fi

mkdir -p "lanedge-playground"
cd "lanedge-playground"

# Clone the theme repository if not already present
if [ ! -d "theme" ]; then
    git clone https://github.com/amerintlxperts/theme.git
fi

# Create symbolic link to the actual lanedge content
ln -sf "../lanedge" docs

# Copy mkdocs.yml from theme if not already present
if [ ! -f mkdocs.yml ]; then
    cp theme/mkdocs.yml .
fi

# The rest would continue as in the original script...
