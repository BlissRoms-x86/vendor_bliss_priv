#!/usr/bin/env bash
FIRMWARE_PATH='app/GWET46WW/$0AGW000.FL1'
MICROCODE_DIR="$TARGET_DIR/kernel/firmware/intel-ucode"
MICROCODE_PATH="$MICROCODE_DIR/06-37-08"

# Fail if an error occurs
set -e

echo " -> Extracting files"
innoextract -s -I "$FIRMWARE_PATH" "$1"

echo " -> Extracting CPU microcode update"
mkdir -p "$MICROCODE_DIR"
dd if="$FIRMWARE_PATH" of="$MICROCODE_PATH" bs=1 skip=5853320 count=52224 status=none
