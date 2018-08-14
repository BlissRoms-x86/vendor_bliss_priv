LOCAL_PATH := vendor/asus/me176c/proprietary

# ASUS public key
PRODUCT_EXTRA_RECOVERY_KEYS += $(LOCAL_PATH)/asus

# Original ASUS system
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/upi_ug31xx:root/sbin/upi_ug31xx:asus \
    $(LOCAL_PATH)/media_profiles.xml:system/etc/media_profiles.xml:asus \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/firmware,system/vendor/firmware)

# MediaSDK OMX plugin (hardware accelerated codecs)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/libmfx_omx_core.so:system/vendor/lib/libmfx_omx_core.so:intel \
    $(LOCAL_PATH)/libmfx_omx_components_hw.so:system/vendor/lib/libmfx_omx_components_hw.so:intel

# Widevine DRM
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/libwvdrmengine.so:system/vendor/lib/mediadrm/libwvdrmengine.so:widevine

# ARM Native bridge (Houdini)
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/houdini,system)
