LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
# Download and extract proprietary files
UPDATE_ENGINE_APPLIER := $(HOST_OUT_EXECUTABLES)/update_engine_applier

.PHONY: proprietary
proprietary: # $(UPDATE_ENGINE_APPLIER)
	UPDATE_ENGINE_APPLIER=$(abspath $(UPDATE_ENGINE_APPLIER)) \
		$(LOCAL_PATH)/setup.sh $(abspath $(LOCAL_PATH))

proprietary: LOCAL_PATH := $(LOCAL_PATH)

# Avoid output buffering since it infers with the sudo confirmation prompt
proprietary: .KATI_NINJA_POOL := console

include $(call all-makefiles-under, $(LOCAL_PATH))

