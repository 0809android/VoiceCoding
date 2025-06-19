#!/bin/bash

# Build the executable
echo "Building VoiceInputApp..."
swift build -c release

# Create app bundle structure
APP_NAME="VoiceInputApp"
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
cp "VoiceInputApp/Info.plist" "$CONTENTS_DIR/"

# Copy entitlements
cp "VoiceInputApp/VoiceInputApp.entitlements" "$RESOURCES_DIR/"

# Sign the app with entitlements
echo "Signing app with entitlements..."
codesign --force --sign - --entitlements "VoiceInputApp/VoiceInputApp.entitlements" "$APP_BUNDLE"

echo "App bundle created: $APP_BUNDLE"

# Run the app
echo "Running VoiceInputApp..."
open "$APP_BUNDLE"