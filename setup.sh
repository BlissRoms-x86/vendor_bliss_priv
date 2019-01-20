#!/usr/bin/env bash
export SCRIPT_DIR="$1"
export SOURCE_DIR="$1/source"
export TARGET_DIR="$1/proprietary"

export ASUS_VERSION="UL-K013-WW-12.10.1.36-user"
ASUS_DOWNLOAD="$ASUS_VERSION.zip"
ASUS_DOWNLOAD_URL="http://dlcdnet.asus.com/pub/ASUS/EeePAD/ME176C/$ASUS_DOWNLOAD"
ASUS_DOWNLOAD_SHA256="b19a2901bd5920b58bd3693243a9edf433656bcee8f454637ee401e28c096469"

export CHROMEOS_RECOVERY="chromeos_11151.33.0_nocturne_recovery_stable-channel_mp"
CHROMEOS_DOWNLOAD="$CHROMEOS_RECOVERY.bin.zip"
CHROMEOS_DOWNLOAD_URL="https://dl.google.com/dl/edgedl/chromeos/recovery/$CHROMEOS_DOWNLOAD"
CHROMEOS_DOWNLOAD_SHA256="f660e18709b023bf9a8ac198c3292cf037ecda3aa566281182d8e38fc0ce6c14"

#CHROMEOS_CHANNEL="canary"
#CHROMEOS_VERSION="11196.0.0"
#CHROMEOS_DOWNLOAD="chromeos_${CHROMEOS_VERSION}_eve_$CHROMEOS_CHANNEL-channel_full_mp.bin-6fc7a89e4795297c76e32385aa4fd5e5.signed"
#CHROMEOS_DOWNLOAD_URL="https://storage.googleapis.com/chromeos-releases-public/$CHROMEOS_CHANNEL-channel/$CHROMEOS_CHANNEL-channel/$CHROMEOS_VERSION/$CHROMEOS_DOWNLOAD"
#export CHROMEOS_DOWNLOAD_SHA256="db4a84069a38f950f6374065dfc905c26f26e8fc22abb6ea6b6bf1588aaa9335"

MICROCODE_DOWNLOAD="cpu30678_plat02_ver00000837_2018-01-25_PRD_F0D56486.bin"
MICROCODE_DOWNLOAD_URL="https://raw.githubusercontent.com/platomav/CPUMicrocodes/079248c4d1d82695555539ef7ad6886c8c4fce3e/Intel/$MICROCODE_DOWNLOAD"
MICROCODE_DOWNLOAD_SHA256="2a5d97c9c50b51f0de3139c127ad3f56a977ee6ee536c9d5854f33c2226485fa"

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
download "$MICROCODE_DOWNLOAD" "$MICROCODE_DOWNLOAD_URL" "$MICROCODE_DOWNLOAD_SHA256"

echo "Deleting old files"
rm -rf "$TARGET_DIR"
mkdir "$TARGET_DIR"

export TEMP_DIR=`mktemp -d`
cd "$TEMP_DIR"

echo "Processing $ASUS_DOWNLOAD"
"$SCRIPT_DIR/extract.asus.sh" "$SOURCE_DIR/$ASUS_DOWNLOAD"

echo "Processing $CHROMEOS_DOWNLOAD"
"$SCRIPT_DIR/extract.chromeos.sh" "$SOURCE_DIR/$CHROMEOS_DOWNLOAD"

echo "Processing $MICROCODE_DOWNLOAD"
"$SCRIPT_DIR/extract.microcode.sh" "$SOURCE_DIR/$MICROCODE_DOWNLOAD"

rm -r "$TEMP_DIR"
echo "Done"
