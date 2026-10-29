#!/bin/bash
set -euo pipefail

if [ "$(uname -s)" != Darwin ]; then
  echo "UsageBar は macOS 専用のためスキップします"
  exit 0
fi

ROOT=$(cd "$(dirname "$0")" && pwd)
bash "$ROOT/build.sh"

DEST="$HOME/Applications/UsageBar.app"
AGENT="$HOME/Library/LaunchAgents/dev.pcmac24041.usagebar.plist"
mkdir -p "$HOME/Applications" "$HOME/Library/LaunchAgents"
launchctl bootout "gui/$(id -u)" "$AGENT" >/dev/null 2>&1 || true
ditto "$ROOT/dist/UsageBar.app" "$DEST"

cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>dev.pcmac24041.usagebar</string>
  <key>ProgramArguments</key><array><string>$DEST/Contents/MacOS/UsageBar</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
</dict></plist>
PLIST
launchctl bootstrap "gui/$(id -u)" "$AGENT"
echo "Installed $DEST"
