#
# Copyright (C) 2018 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := update_engine_applier
LOCAL_SRC_FILES := \
    main.cc \
    update_applier.cc
LOCAL_CPP_EXTENSION := .cc
LOCAL_CFLAGS := $(ue_common_cflags)
LOCAL_CPPFLAGS := $(ue_common_cppflags)
LOCAL_LDFLAGS := $(ue_common_ldflags)
LOCAL_C_INCLUDES := $(ue_common_c_includes)
LOCAL_STATIC_LIBRARIES := \
    libupdate_engine_proxy_resolver \
    libpayload_consumer \
    $(ue_common_static_libraries) \
    $(ue_libpayload_consumer_exported_static_libraries)
LOCAL_SHARED_LIBRARIES := \
    $(ue_common_shared_libraries) \
    $(ue_libpayload_consumer_exported_shared_libraries)
include $(BUILD_HOST_EXECUTABLE)

LOCAL_PATH := system/update_engine

include $(CLEAR_VARS)
LOCAL_MODULE := libupdate_engine_proxy_resolver
LOCAL_SRC_FILES := proxy_resolver.cc
LOCAL_CPP_EXTENSION := .cc
LOCAL_CFLAGS := $(ue_common_cflags)
LOCAL_CPPFLAGS := $(ue_common_cppflags)
LOCAL_LDFLAGS := $(ue_common_ldflags)
LOCAL_C_INCLUDES := $(ue_common_c_includes)
LOCAL_STATIC_LIBRARIES := \
    $(ue_common_static_libraries) \
    $(ue_update_metadata_protos_exported_static_libraries)
LOCAL_SHARED_LIBRARIES := \
    $(ue_common_shared_libraries) \
    $(ue_update_metadata_protos_exported_shared_libraries)
include $(BUILD_HOST_STATIC_LIBRARY)
