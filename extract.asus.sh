#!/usr/bin/env bash

BLUETOOTH_FIRMWARE="system/etc/firmware/BCM2076B1_002.002.004.0132.0141_reduced_2dB.hcd"
ASUS_FILES="boot.img $BLUETOOTH_FIRMWARE"

# Fail if an error occurs
set -e

echo " -> Extracting files"
unzip -q "$1" $ASUS_FILES

echo " -> Extracting boot ramdisk"
python "$ANDROID_BUILD_TOP/system/core/mkbootimg/unpackbootimg" -i boot.img &> /dev/null || :

echo " -> Unpacking boot ramdisk"
mkdir ramdisk && cd ramdisk
cat ../boot.img-ramdisk.gz | gunzip | cpio -Vid --quiet
cd "$TEMP_DIR"

echo " -> Copying files"
cp ramdisk/sbin/upi_ug31xx "$TARGET_DIR"
cp "$BLUETOOTH_FIRMWARE" "$TARGET_DIR/firmware"

echo " -> Patching files"
# /config partition is used by configfs so we move it to /oemcfg
sed -i 's@/config/@/oemcfg/@g' "$TARGET_DIR/upi_ug31xx"
