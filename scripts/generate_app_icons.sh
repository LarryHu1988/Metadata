#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS_DIR="$ROOT_DIR/Sources/PDFLibrarian/Assets.xcassets"
ICONSET_DIR="$ASSETS_DIR/AppIcon.appiconset"
RESOURCES_DIR="$ROOT_DIR/Sources/PDFLibrarian/Resources"
DOCS_ASSETS_DIR="$ROOT_DIR/docs/assets"
BASE_ICON="$DOCS_ASSETS_DIR/PDFLibrarian-logo-1024.png"
ICON_ICNS="$RESOURCES_DIR/AppIcon.icns"

mkdir -p "$ASSETS_DIR" "$ICONSET_DIR" "$RESOURCES_DIR" "$DOCS_ASSETS_DIR"

swift "$ROOT_DIR/scripts/generate_app_logo.swift" "$BASE_ICON"

# size(px) filename
while read -r size file; do
  sips -z "$size" "$size" "$BASE_ICON" --out "$ICONSET_DIR/$file" >/dev/null
done <<'EOF'
16 icon_16x16.png
32 icon_16x16@2x.png
32 icon_32x32.png
64 icon_32x32@2x.png
128 icon_128x128.png
256 icon_128x128@2x.png
256 icon_256x256.png
512 icon_256x256@2x.png
512 icon_512x512.png
1024 icon_512x512@2x.png
EOF

rm -f "$ICONSET_DIR/icon_1024x1024.png"

cat > "$ASSETS_DIR/Contents.json" <<'JSON'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

cat > "$ICONSET_DIR/Contents.json" <<'JSON'
{
  "images" : [
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_16x16@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_32x32@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_128x128@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_256x256@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_512x512@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

iconset_dir="$tmp_dir/AppIcon.iconset"
mkdir -p "$iconset_dir"
cp "$ICONSET_DIR"/icon_16x16.png "$iconset_dir"/
cp "$ICONSET_DIR"/icon_16x16@2x.png "$iconset_dir"/
cp "$ICONSET_DIR"/icon_32x32.png "$iconset_dir"/
cp "$ICONSET_DIR"/icon_32x32@2x.png "$iconset_dir"/
cp "$ICONSET_DIR"/icon_128x128.png "$iconset_dir"/
cp "$ICONSET_DIR"/icon_128x128@2x.png "$iconset_dir"/
cp "$ICONSET_DIR"/icon_256x256.png "$iconset_dir"/
cp "$ICONSET_DIR"/icon_256x256@2x.png "$iconset_dir"/
cp "$ICONSET_DIR"/icon_512x512.png "$iconset_dir"/
cp "$ICONSET_DIR"/icon_512x512@2x.png "$iconset_dir"/

iconutil -c icns "$iconset_dir" -o "$ICON_ICNS"

echo "Generated macOS icon assets:"
echo "  $BASE_ICON"
echo "  $ICONSET_DIR"
echo "  $ICON_ICNS"
