LOCAL_PATH := $(call my-dir)

# Build original mkbootimg too
$(LOCAL_PATH)/mkbootimg.sh: $(HOST_OUT_EXECUTABLES)/mkbootimg$(HOST_EXECUTABLE_SUFFIX)
