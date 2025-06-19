#!/bin/bash

echo "Building VoiceCoding with Swift Package Manager..."

# Clean previous builds
rm -rf .build

# Build the app
swift build -c release

# Find the built executable
EXECUTABLE=".build/release/VoiceCoding"

if [ -f "$EXECUTABLE" ]; then
    echo "Running VoiceCoding..."
    # Run the executable
    "$EXECUTABLE"
else
    echo "Build failed. Executable not found."
    exit 1
fi