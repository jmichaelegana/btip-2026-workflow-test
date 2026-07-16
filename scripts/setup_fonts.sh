#!/usr/bin/env bash
set -euo pipefail

FONTS_DIR="deck/fonts"
INTER_VER="4.0"
INTER_BASE="https://github.com/rsms/inter/releases/download/v${INTER_VER}"
SCP_BASE="https://raw.githubusercontent.com/adobe-fonts/source-code-pro/release/TTF"

mkdir -p "$FONTS_DIR"

# Inter (static TTF)
for style in Regular Bold Italic BoldItalic; do
    [ -f "$FONTS_DIR/Inter-${style}.ttf" ] && continue
    echo "Downloading Inter-${style}..."
    curl -sSL -o "$FONTS_DIR/Inter-${style}.ttf" "${INTER_BASE}/Inter-${style}.ttf"
done

# Source Code Pro (regular only — typst auto-derives bold/italic)
if [ ! -f "$FONTS_DIR/SourceCodePro-Regular.ttf" ]; then
    echo "Downloading Source Code Pro..."
    curl -sSL -o "$FONTS_DIR/SourceCodePro-Regular.ttf" "${SCP_BASE}/SourceCodePro-Regular.ttf"
fi

echo "Fonts ready in $FONTS_DIR/"
ls -lh "$FONTS_DIR"/
