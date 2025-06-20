#!/bin/bash

# Build the executable
echo "Building VoiceCoding..."
swift build -c release

# Create app bundle structure
APP_NAME="VoiceCoding"
BUILD_DIR=".build/release"
APP_BUNDLE="$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Clean old app bundle
rm -rf "$APP_BUNDLE"

# Create directories
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/"

# Copy Info.plist
cp "VoiceCoding/Info.plist" "$CONTENTS_DIR/"

# Copy entitlements
cp "VoiceCoding/VoiceCoding.entitlements" "$RESOURCES_DIR/"

# Sign the app with entitlements
echo "Signing app with entitlements..."
codesign --force --sign - --entitlements "VoiceCoding/VoiceCoding.entitlements" "$APP_BUNDLE"

echo "App bundle created: $APP_BUNDLE"

# Stop any existing instances
echo "Stopping any existing instances..."
pkill -f VoiceCoding || true
sleep 1

# Run the app
echo "Running VoiceCoding..."
open "$APP_BUNDLE"