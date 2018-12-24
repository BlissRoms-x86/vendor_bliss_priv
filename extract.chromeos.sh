#!/usr/bin/env bash
CHROMEOS_EXTRACTED="$CHROMEOS_RECOVERY.bin"
CHROMEOS_ANDROID_VENDOR_IMAGE="opt/google/containers/android/vendor.raw.img"

# Fail if an error occurs
set -e

if [[ -n "$CHROMEOS_RECOVERY" ]]; then
    echo " -> Extracting recovery image"
    unzip -q "$1" "$CHROMEOS_EXTRACTED"

    # Setup loop device
    loop_dev=$(sudo losetup -r -f --show --partscan "$CHROMEOS_EXTRACTED")
    system_image="${loop_dev}p3"
else
    echo " -> Applying update"
    $UPDATE_ENGINE_APPLIER "$1" "$CHROMEOS_DOWNLOAD_SHA256"
    system_image=system.img
fi

echo " -> Mounting system image"
mkdir chromeos
sudo mount -r "$system_image" chromeos

mkdir vendor
sudo mount -r "chromeos/$CHROMEOS_ANDROID_VENDOR_IMAGE" vendor

echo " -> Copying files"
cd vendor

# Widevine DRM
cp bin/hw/android.hardware.drm@1.1-service.widevine "$TARGET_DIR/media"
cp etc/init/android.hardware.drm@1.1-service.widevine.rc "$TARGET_DIR/media"
cp lib/libwvhidl.so "$TARGET_DIR/media"

# Native bridge
mkdir -p "$TARGET_DIR/houdini/"{bin,etc,lib}
cp bin/houdini "$TARGET_DIR/houdini/bin"
cp -r etc/binfmt_misc "$TARGET_DIR/houdini/etc"
cp -r lib/{libhoudini.so,arm} "$TARGET_DIR/houdini/lib"

echo " -> Unmounting recovery image"
cd "$TEMP_DIR"

sudo umount vendor
sudo umount chromeos
[[ -n "$loop_dev" ]] && sudo losetup -d "$loop_dev" || :
