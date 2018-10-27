#!/usr/bin/env bash
export SCRIPT_DIR="$1"
export SOURCE_DIR="$1/source"
export TARGET_DIR="$1/proprietary"

export ASUS_VERSION="UL-K013-WW-12.10.1.36-user"
ASUS_DOWNLOAD="$ASUS_VERSION.zip"
ASUS_DOWNLOAD_URL="http://dlcdnet.asus.com/pub/ASUS/EeePAD/ME176C/$ASUS_DOWNLOAD"
ASUS_DOWNLOAD_SHA256="b19a2901bd5920b58bd3693243a9edf433656bcee8f454637ee401e28c096469"

CHROMEOS_CHANNEL="canary"
CHROMEOS_VERSION="11196.0.0"
CHROMEOS_DOWNLOAD="chromeos_${CHROMEOS_VERSION}_eve_$CHROMEOS_CHANNEL-channel_full_mp.bin-6fc7a89e4795297c76e32385aa4fd5e5.signed"
CHROMEOS_DOWNLOAD_URL="https://storage.googleapis.com/chromeos-releases-public/$CHROMEOS_CHANNEL-channel/$CHROMEOS_CHANNEL-channel/$CHROMEOS_VERSION/$CHROMEOS_DOWNLOAD"
export CHROMEOS_DOWNLOAD_SHA256="db4a84069a38f950f6374065dfc905c26f26e8fc22abb6ea6b6bf1588aaa9335"

LENOVO_DOWNLOAD="gwuj26ww.exe"
LENOVO_DOWNLOAD_URL="https://download.lenovo.com/pccbbs/mobiles/$LENOVO_DOWNLOAD"
LENOVO_DOWNLOAD_SHA256="baf9e5d86805de278f94f9de91809de0cdbbce2c5f91350ea9641fc10dccd895"

# Fail if an error occurs
set -e

function download {
    file="$1"
    url="$2"
    sha256="$3 $file"

    # Check if sha256sum matches local file
    sha256sum -c <<< "$sha256" 2> /dev/null && return

    # Download file
    echo "Downloading $file..."
    echo "$url"
    curl -Lo $file "$url"

    # Check again if new file matches md5sum
    sha256sum -c <<< "$sha256" && return

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
"$SCRIPT_DIR/extract.asus.sh" "$SOURCE_DIR/$ASUS_DOWNLOAD"

echo "Processing $CHROMEOS_DOWNLOAD"
"$SCRIPT_DIR/extract.chromeos.sh" "$SOURCE_DIR/$CHROMEOS_DOWNLOAD"

echo "Processing $LENOVO_DOWNLOAD"
"$SCRIPT_DIR/extract.lenovo.sh" "$SOURCE_DIR/$LENOVO_DOWNLOAD"

rm -r "$TEMP_DIR"
echo "Done"
