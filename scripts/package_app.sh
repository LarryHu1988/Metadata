#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DISPLAY_NAME="PDF Librarian"
APP_EXECUTABLE="PDFLibrarian"
BUNDLE_ID="${BUNDLE_ID:-com.larry.pdflibrarian}"
VERSION="${VERSION:-1.0.1}"
BUILD_DIR="$ROOT_DIR/.build/release"
APP_DIR="$ROOT_DIR/dist/${APP_DISPLAY_NAME}.app"
EXECUTABLE="$BUILD_DIR/$APP_EXECUTABLE"
EXIFTOOL_DIR="${EXIFTOOL_DIR:-}"

resolve_exiftool_dir() {
  if [[ -n "$EXIFTOOL_DIR" && -x "$EXIFTOOL_DIR/bin/exiftool" && -d "$EXIFTOOL_DIR/lib" ]]; then
    echo "$EXIFTOOL_DIR"
    return 0
  fi

  if [[ -d "$ROOT_DIR/vendor/exiftool/libexec" && -x "$ROOT_DIR/vendor/exiftool/libexec/bin/exiftool" ]]; then
    echo "$ROOT_DIR/vendor/exiftool/libexec"
    return 0
  fi

  local hb_opt
  hb_opt="$(ls -d /opt/homebrew/Cellar/exiftool/*/libexec 2>/dev/null | sort -V | tail -n 1 || true)"
  if [[ -n "$hb_opt" && -x "$hb_opt/bin/exiftool" ]]; then
    echo "$hb_opt"
    return 0
  fi

  local hb_usr
  hb_usr="$(ls -d /usr/local/Cellar/exiftool/*/libexec 2>/dev/null | sort -V | tail -n 1 || true)"
  if [[ -n "$hb_usr" && -x "$hb_usr/bin/exiftool" ]]; then
    echo "$hb_usr"
    return 0
  fi

  return 1
}

cd "$ROOT_DIR"
swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$EXECUTABLE" "$APP_DIR/Contents/MacOS/$APP_EXECUTABLE"
chmod +x "$APP_DIR/Contents/MacOS/$APP_EXECUTABLE"

if EXIFTOOL_SRC="$(resolve_exiftool_dir)"; then
  mkdir -p "$APP_DIR/Contents/Resources/ExifTool"
  cp -R "$EXIFTOOL_SRC/bin" "$APP_DIR/Contents/Resources/ExifTool/"
  mkdir -p "$APP_DIR/Contents/Resources/ExifTool/bin"
  cp -R "$EXIFTOOL_SRC/lib/perl5/." "$APP_DIR/Contents/Resources/ExifTool/bin/lib/"
  chmod +x "$APP_DIR/Contents/Resources/ExifTool/bin/exiftool"
  echo "Bundled exiftool from: $EXIFTOOL_SRC"
else
  echo "ERROR: Unable to locate exiftool libexec (bin+lib)."
  echo "Set EXIFTOOL_DIR=/path/to/exiftool/libexec and retry package."
  exit 1
fi

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$APP_DISPLAY_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_DISPLAY_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>$APP_EXECUTABLE</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

if [[ -n "${SIGN_IDENTITY:-}" ]]; then
  codesign --force --deep --options runtime --sign "$SIGN_IDENTITY" "$APP_DIR"
  echo "Signed app with identity: $SIGN_IDENTITY"
else
  # Fallback to ad-hoc bundle signing to avoid broken linker-only signatures
  # that can trigger “app is damaged” on downloaded artifacts.
  codesign --force --deep --sign - "$APP_DIR"
  echo "Signed app with ad-hoc identity (-)"
fi

# Quick sanity check to ensure packaged app has a valid bundle signature.
codesign --verify --deep --strict --verbose=2 "$APP_DIR"

echo "App built: $APP_DIR"
