#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -d "MetadataOrganizerApp.xcodeproj" ]]; then
  echo "Missing MetadataOrganizerApp.xcodeproj, run: xcodegen generate"
  exit 1
fi

TEAM_ID="${TEAM_ID:-}"
EXPORT_METHOD="${EXPORT_METHOD:-developer-id}"
ARCHIVE_PATH="$ROOT_DIR/dist/MetadataOrganizerApp.xcarchive"
EXPORT_PATH="$ROOT_DIR/dist/xcode-export"
EXPORT_PLIST="$ROOT_DIR/dist/ExportOptions.plist"

mkdir -p "$ROOT_DIR/dist"

cat > "$EXPORT_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>$EXPORT_METHOD</string>
  <key>signingStyle</key>
  <string>automatic</string>
  <key>stripSwiftSymbols</key>
  <true/>
</dict>
</plist>
PLIST

if [[ -n "$TEAM_ID" ]]; then
  xcodebuild \
    -project MetadataOrganizerApp.xcodeproj \
    -scheme MetadataOrganizerApp \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    archive
else
  xcodebuild \
    -project MetadataOrganizerApp.xcodeproj \
    -scheme MetadataOrganizerApp \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    archive
fi

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$EXPORT_PLIST" \
  -exportPath "$EXPORT_PATH"

echo "Archive: $ARCHIVE_PATH"
echo "Export: $EXPORT_PATH"
