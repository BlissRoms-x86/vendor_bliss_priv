LOCAL_PATH := vendor/asus/K013/proprietary

# ASUS public key
PRODUCT_EXTRA_RECOVERY_KEYS += $(LOCAL_PATH)/asus

# Original ASUS system
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/upi_ug31xx:root/sbin/upi_ug31xx:asus \
    $(LOCAL_PATH)/media/media_profiles.xml:system/etc/media_profiles.xml:asus \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/firmware,system/vendor/firmware)

# MediaSDK OMX plugin (hardware accelerated codecs)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/media/libmfx_omx_core.so:system/vendor/lib/libmfx_omx_core.so:intel \
    $(LOCAL_PATH)/media/libmfx_omx_components_hw.so:system/vendor/lib/libmfx_omx_components_hw.so:intel \
    $(LOCAL_PATH)/media/mfx_omxil_core.conf:system/etc/mfx_omxil_core.conf:intel

# Widevine DRM
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/media/libwvdrmengine.so:system/vendor/lib/mediadrm/libwvdrmengine.so:widevine

# ARM Native bridge (Houdini)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.dalvik.vm.isa.arm=x86 \
    ro.enable.native.bridge.exec=1

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.dalvik.vm.native.bridge=libhoudini.so

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/houdini,system)
