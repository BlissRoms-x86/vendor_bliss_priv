LOCAL_PATH := vendor/asus/me176c/proprietary

# Original ASUS system
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/upi_ug31xx:root/sbin/upi_ug31xx:asus \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/firmware,system/vendor/firmware)

# Houdini
LOCAL_PATH := $(LOCAL_PATH)/houdini

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/houdini:system/bin/houdini:intel \
    $(LOCAL_PATH)/libhoudini.so:system/lib/libhoudini.so:intel \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/arm,system/lib/arm)
