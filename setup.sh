#!/usr/bin/env bash

SOURCE_DIR="$PWD"
TARGET_DIR="$SOURCE_DIR/proprietary"

ASUS_VERSION="UL-K013-WW-12.10.1.36-user"
BLUETOOTH_FIRMWARE="system/etc/firmware/BCM2076B1_002.002.004.0132.0141_reduced_2dB.hcd"
ASUS_FILES="boot.img $BLUETOOTH_FIRMWARE"

# Fail if an error occurs
set -e

if [ -z "$ANDROID_BUILD_TOP" ]; then
    echo "Please run 'source build/envsetup.sh' before running this script."
    exit 1
fi

function download {
    file="$1"
    url="$2"
    md5="$3 $file"

    # Check if md5sum matches local file
    md5sum -c <<< "$md5" 2> /dev/null && return

    # Download file
    echo "Downloading $file..."
    curl -Lo $file "$url"

    # Check again if new file matches md5sum
    md5sum -c <<< "$md5" && return

    # Remove invalid file
    rm -f "$file"

    # Report error
    echo "Cannot download $file. Please try again later."
    return 1
}

echo "Downloading files..."

# Original ASUS system
ASUS_VERSION="UL-K013-WW-12.10.1.36-user"
download "$ASUS_VERSION.zip" "http://dlcdnet.asus.com/pub/ASUS/EeePAD/ME176C/$ASUS_VERSION.zip" 60ba4a2068e4e8140a6c2accb7c83d19
download houdini.sfs "http://goo.gl/JsoX2C" b126529f9d78b5b5b7f8c9ff650f6e71

echo "Deleting old files"
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR/firmware"

TEMP_DIR=`mktemp -d`
cd "$TEMP_DIR"

echo "Extracting files"
unzip -q "$SOURCE_DIR/$ASUS_VERSION.zip" $ASUS_FILES

echo "Extracting boot ramdisk"
python "$ANDROID_BUILD_TOP/system/core/mkbootimg/unpackbootimg" -i boot.img &> /dev/null || :

echo "Unpacking boot ramdisk"
mkdir ramdisk && cd ramdisk
cat ../boot.img-ramdisk.gz | gunzip | cpio -Vid --quiet
cd "$TEMP_DIR"

echo "Copying files"
cp ramdisk/sbin/upi_ug31xx "$TARGET_DIR"
cp "$BLUETOOTH_FIRMWARE" "$TARGET_DIR/firmware"

cd "$SOURCE_DIR"
rm -rf "$TEMP_DIR"

echo "Patching files"

# /config partition is used by configfs so we move it to /oemcfg
sed -i 's@/config/@/oemcfg/@g' "$TARGET_DIR/upi_ug31xx"

echo "Extracting native bridge"
mkdir "$TARGET_DIR/houdini"
unsquashfs -d "$TARGET_DIR/houdini/arm" houdini.sfs
mv "$TARGET_DIR/houdini/arm/"{houdini,libhoudini.so} "$TARGET_DIR/houdini"

