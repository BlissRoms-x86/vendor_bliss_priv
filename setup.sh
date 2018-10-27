#!/usr/bin/env bash
export SOURCE_DIR="$1"
export TARGET_DIR="$SOURCE_DIR/proprietary"

export ASUS_VERSION="UL-K013-WW-12.10.1.36-user"
ASUS_DOWNLOAD="$ASUS_VERSION.zip"
ASUS_DOWNLOAD_URL="http://dlcdnet.asus.com/pub/ASUS/EeePAD/ME176C/$ASUS_DOWNLOAD"
ASUS_DOWNLOAD_SHA256="b19a2901bd5920b58bd3693243a9edf433656bcee8f454637ee401e28c096469"

export CHROMEOS_VERSION="chromeos_10176.76.0_eve_recovery_stable-channel_mp"
CHROMEOS_DOWNLOAD="$CHROMEOS_VERSION.bin.zip"
CHROMEOS_DOWNLOAD_URL="https://dl.google.com/dl/edgedl/chromeos/recovery/$CHROMEOS_DOWNLOAD"
CHROMEOS_DOWNLOAD_SHA256="00b3c9406effd0f3fe83a65c7f5440eb677bd9bdec35e0c2fe048045e3aebc2f"

LENOVO_DOWNLOAD="gwuj26ww.exe"
LENOVO_DOWNLOAD_URL="https://download.lenovo.com/pccbbs/mobiles/$LENOVO_DOWNLOAD"
LENOVO_DOWNLOAD_SHA256="baf9e5d86805de278f94f9de91809de0cdbbce2c5f91350ea9641fc10dccd895"

# Fail if an error occurs
set -e

function download {
    file="$1"
    url="$2"
    sha1="$3 $file"

    # Check if sha1sum matches local file
    sha256sum -c <<< "$sha1" 2> /dev/null && return

    # Download file
    echo "Downloading $file..."
    curl -Lo $file "$url"

    # Check again if new file matches md5sum
    sha1sum -c <<< "$sha1" && return

    # Remove invalid file
    rm -f "$file"

    # Report error
    echo "Cannot download $file. Please try again later."
    return 1
}

echo "Downloading files..."
cd "$SOURCE_DIR"
download "$ASUS_DOWNLOAD" "$ASUS_DOWNLOAD_URL" "$ASUS_DOWNLOAD_SHA256"
download "$CHROMEOS_DOWNLOAD" "$CHROMEOS_DOWNLOAD_URL" "$CHROMEOS_DOWNLOAD_SHA256"
download "$LENOVO_DOWNLOAD" "$LENOVO_DOWNLOAD_URL" "$LENOVO_DOWNLOAD_SHA256"

echo "Deleting old files"
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR/firmware"
mkdir -p "$TARGET_DIR/media"

export TEMP_DIR=`mktemp -d`
cd "$TEMP_DIR"

echo "Processing $ASUS_DOWNLOAD"
"$SOURCE_DIR/extract.asus.sh" "$SOURCE_DIR/$ASUS_DOWNLOAD"

echo "Processing $CHROMEOS_DOWNLOAD"
"$SOURCE_DIR/extract.chromeos.sh" "$SOURCE_DIR/$CHROMEOS_DOWNLOAD"

echo "Processing $LENOVO_DOWNLOAD"
"$SOURCE_DIR/extract.lenovo.sh" "$SOURCE_DIR/$LENOVO_DOWNLOAD"

rm -r "$TEMP_DIR"
echo "Done"
