#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
APP_NAME="URLCap"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "Building $APP_NAME..."

# Remove old build directory and recreate
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Compile the AppleScript into an app bundle
echo "Compiling AppleScript application..."
osacompile -o "$APP_BUNDLE" "$SCRIPT_DIR/URLCap.applescript"

# Replace the Info.plist with our custom one
echo "Installing custom Info.plist..."
cp "$SCRIPT_DIR/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

# Compile the Swift helper directly into the app bundle
echo "Compiling url-handler-helper..."
swiftc -o "$APP_BUNDLE/Contents/Resources/url-handler-helper" "$SCRIPT_DIR/url-handler-helper.swift" -framework CoreServices 2>/dev/null || true

echo ""
echo "Build complete: $APP_BUNDLE"
echo ""
echo "To run: open $APP_BUNDLE"
echo ""
echo "Note: The first time you open a URL while URLCap is active,"
echo "      macOS may ask you to confirm the handler change."
