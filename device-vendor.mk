LOCAL_PATH := vendor/asus/K013/proprietary

# ASUS public key
PRODUCT_EXTRA_RECOVERY_KEYS += $(LOCAL_PATH)/asus

# Original ASUS system
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/upi_ug31xx:root/sbin/upi_ug31xx:asus \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/firmware,$(TARGET_COPY_OUT_VENDOR)/firmware)

# Widevine DRM
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/drm/android.hardware.drm@1.1-service.widevine:$(TARGET_COPY_OUT_VENDOR)/bin/hw/android.hardware.drm@1.1-service.widevine:widevine \
    $(LOCAL_PATH)/drm/android.hardware.drm@1.1-service.widevine.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/android.hardware.drm@1.1-service.widevine.rc:widevine \
    $(LOCAL_PATH)/drm/libwvhidl.so:$(TARGET_COPY_OUT_VENDOR)/lib/libwvhidl.so:widevine

# ARM Native bridge (Houdini)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.dalvik.vm.isa.arm=x86 \
    ro.enable.native.bridge.exec=1

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.dalvik.vm.native.bridge=libhoudini.so

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/houdini,$(TARGET_COPY_OUT_SYSTEM))
