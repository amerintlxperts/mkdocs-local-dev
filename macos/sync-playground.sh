#!/bin/bash

# Sync script for updating lanedge-playground with latest changes
# Usage: ./sync-playground.sh <track>

set -e  # Exit on any error

TRACK=$1
if [ -z "$TRACK" ]; then
    echo "ERROR: Usage: $0 <track>"
    echo "Example: $0 lanedge"
    exit 1
fi

PLAYGROUND_DIR="$TRACK-playground"

if [ ! -d "$PLAYGROUND_DIR" ]; then
    echo "ERROR: $PLAYGROUND_DIR directory not found."
    echo "Please run ./setuplocal.sh $TRACK first to set up the playground."
    exit 1
fi

echo "=== Syncing $TRACK content to $PLAYGROUND_DIR ==="

cd "$PLAYGROUND_DIR/docs"

# Check if this is a git repository
if [ ! -d ".git" ]; then
    echo "ERROR: docs directory is not a git repository."
    echo "Please re-run ./setuplocal.sh $TRACK to set up properly."
    exit 1
fi

# Pull latest changes
echo "Pulling latest changes from main repository..."
git pull origin main

cd ..

echo ""
echo "Sync complete!"
echo "Your playground now has the latest content from the main repository."
echo ""
echo "To serve the updated docs:"
echo "    source ../venv/bin/activate"
echo "    mkdocs serve"
echo ""
