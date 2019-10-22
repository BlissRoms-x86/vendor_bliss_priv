#!/usr/bin/env bash

export SCRIPT_DIR=$PWD
export SOURCE_DIR=$PWD"/vendor/bliss_priv/source"
export TARGET_DIR=$PWD"/vendor/bliss_priv/proprietary"

export CHROMEOS_RECOVERY="chromeos_11151.33.0_nocturne_recovery_stable-channel_mp"
CHROMEOS_DOWNLOAD="$CHROMEOS_RECOVERY.bin.zip"
CHROMEOS_DOWNLOAD_URL="https://dl.google.com/dl/edgedl/chromeos/recovery/$CHROMEOS_DOWNLOAD"
CHROMEOS_DOWNLOAD_SHA256="f660e18709b023bf9a8ac198c3292cf037ecda3aa566281182d8e38fc0ce6c14"

#CHROMEOS_CHANNEL="canary"
#CHROMEOS_VERSION="11196.0.0"
#CHROMEOS_DOWNLOAD="chromeos_${CHROMEOS_VERSION}_eve_$CHROMEOS_CHANNEL-channel_full_mp.bin-6fc7a89e4795297c76e32385aa4fd5e5.signed"
#CHROMEOS_DOWNLOAD_URL="https://storage.googleapis.com/chromeos-releases-public/$CHROMEOS_CHANNEL-channel/$CHROMEOS_CHANNEL-channel/$CHROMEOS_VERSION/$CHROMEOS_DOWNLOAD"
#export CHROMEOS_DOWNLOAD_SHA256="db4a84069a38f950f6374065dfc905c26f26e8fc22abb6ea6b6bf1588aaa9335"

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
mkdir "$SOURCE_DIR" && mkdir "$TARGET_DIR"
cd "$SOURCE_DIR"

download "$CHROMEOS_DOWNLOAD" "$CHROMEOS_DOWNLOAD_URL" "$CHROMEOS_DOWNLOAD_SHA256"

echo "Deleting old files"
rm -rf "$TARGET_DIR"
mkdir "$TARGET_DIR"

export TEMP_DIR=`mktemp -d`
cd "$TEMP_DIR"

echo "Processing $CHROMEOS_DOWNLOAD"
"$SCRIPT_DIR/vendor/bliss_priv/extract.chromeos.sh" "$SOURCE_DIR/$CHROMEOS_DOWNLOAD"

rm -r "$TEMP_DIR"
echo "Done"
