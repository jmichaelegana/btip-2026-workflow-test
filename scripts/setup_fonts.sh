#!/usr/bin/env bash
set -euo pipefail

FONTS_DIR="deck/fonts"
INTER_VER="4.0"
INTER_ZIP="Inter-${INTER_VER}.zip"
INTER_URL="https://github.com/rsms/inter/releases/download/v${INTER_VER}/${INTER_ZIP}"
SCP_BASE="https://raw.githubusercontent.com/adobe-fonts/source-code-pro/release/TTF"

mkdir -p "$FONTS_DIR"

# --- Inter (static TTF from release zip) ---
# The zip has variable fonts at root and static TTFs under extras/ttf/
NEED_INTER=false
for style in Regular Bold Italic BoldItalic; do
    [ -f "$FONTS_DIR/Inter-${style}.ttf" ] || NEED_INTER=true
done

if $NEED_INTER; then
    echo "Downloading Inter ${INTER_VER}..."
    curl -sSL -o "/tmp/${INTER_ZIP}" "${INTER_URL}"

    for style in Regular Bold Italic BoldItalic; do
        [ -f "$FONTS_DIR/Inter-${style}.ttf" ] && continue
        echo "Extracting Inter-${style}..."
        unzip -qjo "/tmp/${INTER_ZIP}" "extras/ttf/Inter-${style}.ttf" -d "$FONTS_DIR"
    done

    rm -f "/tmp/${INTER_ZIP}"
fi

# --- Source Code Pro (regular only — typst auto-derives bold/italic) ---
if [ ! -f "$FONTS_DIR/SourceCodePro-Regular.ttf" ]; then
    echo "Downloading Source Code Pro..."
    curl -sSL -o "$FONTS_DIR/SourceCodePro-Regular.ttf" "${SCP_BASE}/SourceCodePro-Regular.ttf"
fi

echo "Fonts ready:"
ls -lh "$FONTS_DIR"/
