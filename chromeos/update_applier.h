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

#pragma once

#include <brillo/message_loops/base_message_loop.h>
#include <update_engine/common/action_processor.h>
#include <update_engine/common/error_code.h>
#include <update_engine/common/http_fetcher.h>
#include <update_engine/common/prefs_interface.h>
#include <update_engine/payload_consumer/download_action.h>
#include <update_engine/payload_consumer/install_plan.h>

namespace chromeos_update_engine {

class UpdateApplier : public ActionProcessorDelegate {
 public:
  UpdateApplier(const InstallPlan &install_plan,
                PrefsInterface* prefs,
                BootControlInterface* boot_control,
                HardwareInterface* hardware,
                HttpFetcher *fetcher);

  ErrorCode Run();

  void ProcessingDone(const ActionProcessor* processor, ErrorCode code) override;

 private:
  brillo::BaseMessageLoop loop_;
  InstallPlanAction install_plan_action_;
  DownloadAction download_action_;
  ErrorCode error_code_;

  DISALLOW_COPY_AND_ASSIGN(UpdateApplier);
};

}
