#!/usr/bin/env bash
set -e

MICROCODE_RAMDISK="vendor/asus/me176c/proprietary/microcode.img"

if [ ! -f "$MICROCODE_RAMDISK" ]; then
    echo "Warning: $MICROCODE_RAMDISK does not exist"
    exec mkbootimg "$@"
fi

# Search original ramdisk in command line arguments
found=0
for arg
do
    if (( found )); then
        ramdisk=$arg
        break
    elif [[ $arg == "--ramdisk" ]]; then
        found=1
    fi
done

if [ -z "$ramdisk" ]; then
    exec mkbootimg "$@"
fi

# Create temporary file for new ramdisk
tmp_ramdisk=$(mktemp)
trap "rm -f $tmp_ramdisk" EXIT

# Concatenate ramdisks
cat "$MICROCODE_RAMDISK" "$ramdisk" > "$tmp_ramdisk"

# Override ramdisk
mkbootimg "$@" --ramdisk "$tmp_ramdisk"
