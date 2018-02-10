#!/usr/bin/env bash

BLUETOOTH_FIRMWARE="system/etc/firmware/BCM2076B1_002.002.004.0132.0141_reduced_2dB.hcd"
WIFI_NVRAM="system/etc/nvram.txt"
MEDIA_PROFILES="system/etc/media_profiles.xml"
PUBLIC_KEY="META-INF/com/android/otacert"
ASUS_FILES="$PUBLIC_KEY boot.img $WIFI_NVRAM $MEDIA_PROFILES $BLUETOOTH_FIRMWARE"

# Fail if an error occurs
set -e

echo " -> Extracting files"
unzip -q "$1" $ASUS_FILES

echo " -> Extracting boot ramdisk"
"$SOURCE_DIR/unpackbootimg.py" boot.img

echo " -> Unpacking boot ramdisk"
mkdir ramdisk && cd ramdisk
cat ../ramdisk.img | gunzip | cpio -Vid --quiet
cd "$TEMP_DIR"

echo " -> Copying files"
cp ramdisk/sbin/upi_ug31xx "$TARGET_DIR"
cp "$PUBLIC_KEY" "$TARGET_DIR/asus.x509.pem"
mkdir "$TARGET_DIR/firmware/brcm" && cp "$WIFI_NVRAM" "$TARGET_DIR/firmware/brcm/brcmfmac43362-sdio.txt"
cp "$MEDIA_PROFILES" "$TARGET_DIR"
cp "$BLUETOOTH_FIRMWARE" "$TARGET_DIR/firmware"

echo " -> Patching files"
# /config partition is used by configfs so we move it to /vnddat (vendor data)
sed -i 's@/config/@/vnddat/@g' "$TARGET_DIR/upi_ug31xx"
