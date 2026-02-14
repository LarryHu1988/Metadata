#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DISPLAY_NAME="PDF Librarian"
APP_SLUG="PDFLibrarian"
VERSION="${VERSION:-1.0.2}"
APP_PATH="$ROOT_DIR/dist/${APP_DISPLAY_NAME}.app"
ZIP_PATH="$ROOT_DIR/dist/${APP_SLUG}-${VERSION}.zip"
DMG_PATH="$ROOT_DIR/dist/${APP_SLUG}-${VERSION}.dmg"
DMG_STAGE_DIR="$ROOT_DIR/dist/.dmg-stage-${VERSION}"

# Always rebuild the app before creating release assets to avoid packaging
# a stale .app that may remain in dist from previous versions.
if [[ "${SKIP_PACKAGE:-0}" != "1" ]]; then
  VERSION="$VERSION" "$ROOT_DIR/scripts/package_app.sh"
elif [[ ! -d "$APP_PATH" ]]; then
  echo "ERROR: SKIP_PACKAGE=1 but app bundle does not exist at: $APP_PATH"
  exit 1
fi

rm -f "$ZIP_PATH" "$DMG_PATH"

# Zip: users can extract and drag .app to /Applications
# DMG: includes /Applications symlink for direct drag-install

ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

rm -rf "$DMG_STAGE_DIR"
mkdir -p "$DMG_STAGE_DIR"
cp -R "$APP_PATH" "$DMG_STAGE_DIR/"
ln -s /Applications "$DMG_STAGE_DIR/Applications"

hdiutil create -volname "$APP_DISPLAY_NAME" -srcfolder "$DMG_STAGE_DIR" -ov -format UDZO "$DMG_PATH"

rm -rf "$DMG_STAGE_DIR"

echo "Release assets created:"
echo "  $ZIP_PATH"
echo "  $DMG_PATH"
