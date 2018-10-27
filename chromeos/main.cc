//
// Copyright (C) 2018 The Android Open Source Project
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include <stdlib.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sysexits.h>
#include <xz.h>

#include <base/strings/string_number_conversions.h>
#include <update_engine/common/fake_boot_control.h>
#include <update_engine/common/fake_hardware.h>
#include <update_engine/common/file_fetcher.h>
#include <update_engine/common/prefs.h>
#include <update_engine/common/terminator.h>
#include <update_engine/payload_consumer/install_plan.h>
#include <update_engine/payload_consumer/payload_constants.h>

#include "update_applier.h"

namespace {

#define FILE_URL_PROTOCOL    "file://"
#define SYSTEM_IMAGE_OUTPUT  "system.img"
#define BOOT_IMAGE_OUTPUT    "boot.img"

uint64_t stat_file_size(const char *path) {
  struct stat sb;
  if (stat(path, &sb)) {
    PLOG(ERROR) << "Failed to get payload file size from " << path;
    return 0;
  }
  return sb.st_size;
}

void create_empty_file(const char *path) {
    int fd = creat(path, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
    if (fd < 0) {
        PLOG(ERROR) << "Failed to create empty file at " << path;
        return;
    }
    close(fd);
}

}

namespace chromeos_update_engine {
namespace {

static ErrorCode ApplyUpdate(const char *url, const char *path, brillo::Blob hash) {
  LOG(INFO) << "Applying payload: " << path;

  InstallPlan install_plan = {
    .download_url = url,
    .payloads = {{
      .type = InstallPayloadType::kFull,
      .size = stat_file_size(path),
      .hash = hash,
    }},
    .target_slot = 0,
    .run_post_install = false,
  };

  MemoryPrefs prefs;
  FakeBootControl boot_control;
  FakeHardware hardware;

  boot_control.SetPartitionDevice(kLegacyPartitionNameRoot, install_plan.target_slot, SYSTEM_IMAGE_OUTPUT);
  boot_control.SetPartitionDevice(kLegacyPartitionNameKernel, install_plan.target_slot, BOOT_IMAGE_OUTPUT);

  // Create output files
  create_empty_file(SYSTEM_IMAGE_OUTPUT);
  create_empty_file(BOOT_IMAGE_OUTPUT);

  UpdateApplier applier{install_plan, &prefs, &boot_control, &hardware, new FileFetcher};
  return applier.Run();
}

}
}

int main(int argc, char** argv) {
  if (argc != 3) {
    printf("Usage: %s <payload.signed> <sha256 hash>\n",
           argc > 0 ? argv[0] : "update_engine_applier");
    return EX_USAGE;
  }
  chromeos_update_engine::Terminator::Init();

  // xz-embedded requires to initialize its CRC-32 table once on startup.
  xz_crc32_init();

  // Resolve absolute path to payload file
  char url[strlen(FILE_URL_PROTOCOL) + PATH_MAX] = FILE_URL_PROTOCOL;
  char *path = &url[strlen(FILE_URL_PROTOCOL)];
  if (!realpath(argv[1], path)) {
    perror("Failed to resolve absolute path to payload file");
    return EX_IOERR;
  }

  // Decode the given sha256 hash
  brillo::Blob hash;
  if (!base::HexStringToBytes(argv[2], &hash)) {
    printf("Failed to convert payload hash from hex string to bytes: %s\n",
           argv[2]);
    return EX_USAGE;
  }

  // Apply the update
  return static_cast<int>(chromeos_update_engine::ApplyUpdate(url, path, hash));
}
