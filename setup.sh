#!/usr/bin/env bash

export SOURCE_DIR="$PWD"
export TARGET_DIR="$SOURCE_DIR/proprietary"

export ASUS_VERSION="UL-K013-WW-12.10.1.36-user"
ASUS_DOWNLOAD="$ASUS_VERSION.zip"
ASUS_DOWNLOAD_URL="http://dlcdnet.asus.com/pub/ASUS/EeePAD/ME176C/$ASUS_DOWNLOAD"
ASUS_DOWNLOAD_MD5="60ba4a2068e4e8140a6c2accb7c83d19"

export CHROMEOS_VERSION="chromeos_9901.54.0_eve_recovery_stable-channel_mp"
CHROMEOS_DOWNLOAD="$CHROMEOS_VERSION.bin.zip"
CHROMEOS_DOWNLOAD_URL="https://dl.google.com/dl/edgedl/chromeos/recovery/$CHROMEOS_DOWNLOAD"
CHROMEOS_DOWNLOAD_MD5="5e0b831d96d46742361a94bfb57f3de2"

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
download "$ASUS_DOWNLOAD" "$ASUS_DOWNLOAD_URL" "$ASUS_DOWNLOAD_MD5"
download "$CHROMEOS_DOWNLOAD" "$CHROMEOS_DOWNLOAD_URL" "$CHROMEOS_DOWNLOAD_MD5"

echo "Deleting old files"
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR/firmware"

export TEMP_DIR=`mktemp -d`
cd "$TEMP_DIR"

echo "Processing $ASUS_DOWNLOAD"
"$SOURCE_DIR/extract.asus.sh" "$SOURCE_DIR/$ASUS_DOWNLOAD"

echo "Processing $CHROMEOS_DOWNLOAD"
"$SOURCE_DIR/extract.chromeos.sh" "$SOURCE_DIR/$CHROMEOS_DOWNLOAD"

rm -r "$TEMP_DIR"
echo "Done"
