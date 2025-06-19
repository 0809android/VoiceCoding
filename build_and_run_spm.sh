#!/bin/bash

echo "Building VoiceInputApp with Swift Package Manager..."

# Clean previous builds
rm -rf .build

# Build the app
swift build -c release

# Find the built executable
EXECUTABLE=".build/release/VoiceInputApp"

if [ -f "$EXECUTABLE" ]; then
    echo "Running VoiceInputApp..."
    # Run the executable
    "$EXECUTABLE"
else
    echo "Build failed. Executable not found."
    exit 1
fi