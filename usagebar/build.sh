#!/bin/bash
set -euo pipefail

if [ "$(uname -s)" != Darwin ]; then
  echo "UsageBar は macOS 専用のためスキップします"
  exit 0
fi

ROOT=$(cd "$(dirname "$0")" && pwd)
APP="$ROOT/dist/UsageBar.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>dev.pcmac24041.usagebar</string>
  <key>CFBundleName</key><string>UsageBar</string>
  <key>CFBundleExecutable</key><string>UsageBar</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST

MODULE_CACHE="$ROOT/dist/module-cache"
mkdir -p "$MODULE_CACHE"
CLANG_MODULE_CACHE_PATH="$MODULE_CACHE" SWIFT_MODULE_CACHE_PATH="$MODULE_CACHE" \
  swiftc -O -Xcc "-fmodules-cache-path=$MODULE_CACHE" \
  -o "$APP/Contents/MacOS/UsageBar" "$ROOT/UsageBar.swift"
cp "$ROOT/usage.py" "$APP/Contents/Resources/usage.py"
echo "$APP"
