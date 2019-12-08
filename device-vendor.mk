LOCAL_PATH := vendor/bliss_priv/proprietary

# Widevine DRM
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/drm/android.hardware.drm@1.1-service.widevine:$(TARGET_COPY_OUT_VENDOR)/bin/hw/android.hardware.drm@1.1-service.widevine:widevine \
    $(LOCAL_PATH)/drm/android.hardware.drm@1.1-service.widevine.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/android.hardware.drm@1.1-service.widevine.rc:widevine \
    $(LOCAL_PATH)/drm/libwvhidl.so:$(TARGET_COPY_OUT_VENDOR)/lib/libwvhidl.so:widevine

# ARM Native bridge (Houdini)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.dalvik.vm.isa.arm=x86 \
    ro.enable.native.bridge.exec=1

# Bundle Houdini as ARM on x86 native bridge
WITH_NATIVE_BRIDGE := true

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.dalvik.vm.native.bridge=libhoudini.so

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/houdini,$(TARGET_COPY_OUT_SYSTEM))
