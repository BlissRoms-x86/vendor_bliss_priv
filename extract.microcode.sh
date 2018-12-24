#!/usr/bin/env bash
MICROCODE_DIR="$TARGET_DIR/kernel/firmware/intel-ucode"
MICROCODE_PATH="$MICROCODE_DIR/06-37-08"

# Fail if an error occurs
set -e

echo " -> Copying files"
mkdir -p "$MICROCODE_DIR"
cp "$1" "$MICROCODE_PATH"
