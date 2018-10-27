LOCAL_PATH := vendor/bliss_priv/proprietary

# Widevine DRM
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/media/android.hardware.drm@1.1-service.widevine:system/vendor/bin/hw/android.hardware.drm@1.1-service.widevine:widevine \
    $(LOCAL_PATH)/media/android.hardware.drm@1.1-service.widevine.rc:system/vendor/etc/init/android.hardware.drm@1.1-service.widevine.rc:widevine \
    $(LOCAL_PATH)/media/libwvhidl.so:system/vendor/lib/libwvhidl.so:widevine

# ARM Native bridge (Houdini)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.dalvik.vm.isa.arm=x86 \
    ro.enable.native.bridge.exec=1

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.dalvik.vm.native.bridge=libhoudini.so

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/houdini,system)
