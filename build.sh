#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="URLCap"
APP_BUNDLE="$SCRIPT_DIR/$APP_NAME.app"

echo "Building $APP_NAME..."

# Remove old build
rm -rf "$APP_BUNDLE"

# Compile the Swift helper
echo "Compiling url-handler-helper..."
swiftc -o "$SCRIPT_DIR/url-handler-helper" "$SCRIPT_DIR/url-handler-helper.swift" -framework CoreServices 2>/dev/null || true

# Compile the AppleScript into an app bundle
echo "Compiling AppleScript application..."
osacompile -o "$APP_BUNDLE" "$SCRIPT_DIR/URLCap.applescript"

# Replace the Info.plist with our custom one
echo "Installing custom Info.plist..."
cp "$SCRIPT_DIR/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

# Copy the helper tool to Resources
echo "Installing url-handler-helper..."
cp "$SCRIPT_DIR/url-handler-helper" "$APP_BUNDLE/Contents/Resources/"
chmod +x "$APP_BUNDLE/Contents/Resources/url-handler-helper"

# Update Launch Services database so macOS knows about our URL handlers
echo "Updating Launch Services database..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_BUNDLE"

echo ""
echo "Build complete: $APP_BUNDLE"
echo ""
echo "To run: open $APP_BUNDLE"
echo ""
echo "Note: The first time you open a URL while URLCap is active,"
echo "      macOS may ask you to confirm the handler change."
