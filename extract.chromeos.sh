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
mkdir "$TARGET_DIR/drm"
cp bin/hw/android.hardware.drm@1.1-service.widevine "$TARGET_DIR/drm"
cp etc/init/android.hardware.drm@1.1-service.widevine.rc "$TARGET_DIR/drm"
cp lib/libwvhidl.so "$TARGET_DIR/drm"

# Native bridge (Houdini)

# Create init script
mkdir -p "$TARGET_DIR/houdini/etc/init"
cat > "$TARGET_DIR/houdini/etc/init/houdini.rc" <<EOF
on property:ro.enable.native.bridge.exec=1
    mount binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc
    copy /system/etc/binfmt_misc/arm_exe /proc/sys/fs/binfmt_misc/register
    copy /system/etc/binfmt_misc/arm_dyn /proc/sys/fs/binfmt_misc/register
EOF
touch -hr vendor/etc/init "$TARGET_DIR/houdini/etc/init"{/houdini.rc,}

# Copy files
mkdir -p "$TARGET_DIR/houdini/"{bin,etc,lib}
cp bin/houdini "$TARGET_DIR/houdini/bin"
cp -r etc/binfmt_misc "$TARGET_DIR/houdini/etc"
cp -r etc/init/houdini.rc "$TARGET_DIR/houdini/etc/init"
cp -r lib/{libhoudini.so,arm} "$TARGET_DIR/houdini/lib"

echo " -> Unmounting recovery image"
cd "$TEMP_DIR"

sudo umount vendor
sudo umount chromeos
[[ -n "$loop_dev" ]] && sudo losetup -d "$loop_dev" || :
