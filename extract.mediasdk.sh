#!/usr/bin/env bash
MEDIASDK_DIR="mediasdk/broxton/lib/x86"
MEDIASDK_FILES="$MEDIASDK_DIR/libmfx_omx_*"

# Fail if an error occurs
set -e

echo " -> Extracting files"
tar xzf "$1" --strip-components=1
cp $MEDIASDK_FILES "$TARGET_DIR/media"

cat > "$TARGET_DIR/media/mfx_omxil_core.conf" <<EOF
OMX.Intel.hw_vd.h264 : libmfx_omx_components_hw.so
OMX.Intel.hw_ve.h264 : libmfx_omx_components_hw.so
EOF
