#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DISPLAY_NAME="PDF Librarian"
APP_SLUG="PDFLibrarian"
VERSION="${VERSION:-1.0.1}"
APP_PATH="${APP_PATH:-$ROOT_DIR/dist/${APP_DISPLAY_NAME}.app}"
ZIP_PATH="$ROOT_DIR/dist/${APP_SLUG}-${VERSION}.zip"
DMG_PATH="$ROOT_DIR/dist/${APP_SLUG}-${VERSION}.dmg"
DMG_STAGE_DIR="$ROOT_DIR/dist/.dmg-stage-${VERSION}"

if [[ -z "${SIGN_IDENTITY:-}" ]]; then
  echo "Missing SIGN_IDENTITY"
  exit 1
fi

codesign --force --deep --options runtime --sign "$SIGN_IDENTITY" "$APP_PATH"

# Create zip for notarization
rm -f "$ZIP_PATH" "$DMG_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

if [[ -n "${AC_KEY_ID:-}" && -n "${AC_ISSUER_ID:-}" && -n "${AC_KEY_PATH:-}" ]]; then
  xcrun notarytool submit "$ZIP_PATH" \
    --key "$AC_KEY_PATH" \
    --key-id "$AC_KEY_ID" \
    --issuer "$AC_ISSUER_ID" \
    --wait
  xcrun stapler staple "$APP_PATH"
fi

rm -rf "$DMG_STAGE_DIR"
mkdir -p "$DMG_STAGE_DIR"
cp -R "$APP_PATH" "$DMG_STAGE_DIR/"
ln -s /Applications "$DMG_STAGE_DIR/Applications"
hdiutil create -volname "$APP_DISPLAY_NAME" -srcfolder "$DMG_STAGE_DIR" -ov -format UDZO "$DMG_PATH"
rm -rf "$DMG_STAGE_DIR"

echo "Distribution files:"
echo "  $ZIP_PATH"
echo "  $DMG_PATH"
