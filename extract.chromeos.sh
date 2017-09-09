#!/usr/bin/env bash

CHROMEOS_EXTRACTED="$CHROMEOS_VERSION.bin"
CHROMEOS_ANDROID_VENDOR_IMAGE=""

# Fail if an error occurs
set -e

# Unzip the partitions
echo " -> Extracting recovery image"
unzip -q "$1" "$CHROMEOS_EXTRACTED"

echo " -> Mounting recovery image"

# Setup loop device
loop_dev=$(sudo losetup -r -f --show --partscan "$CHROMEOS_EXTRACTED")

mkdir chromeos
sudo mount "${loop_dev}p3" chromeos

mkdir vendor
sudo mount -r "chromeos/opt/google/containers/android/vendor.raw.img" vendor

echo " -> Copying files"
cd vendor

# Widevine DRM
cp lib/mediadrm/libwvdrmengine.so "$TARGET_DIR"

# Native bridge
mkdir -p "$TARGET_DIR/houdini/"{bin,etc,lib}
cp bin/houdini "$TARGET_DIR/houdini/bin"
cp -r etc/binfmt_misc "$TARGET_DIR/houdini/etc"
cp -r lib/{libhoudini.so,arm} "$TARGET_DIR/houdini/lib"

echo " -> Unmounting recovery image"
cd "$TEMP_DIR"

sudo umount vendor
sudo umount chromeos
sudo losetup -d "$loop_dev"
