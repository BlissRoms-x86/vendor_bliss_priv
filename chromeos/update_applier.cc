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

#include "update_applier.h"

#include <base/bind.h>
#include <update_engine/common/action.h>

namespace chromeos_update_engine {

UpdateApplier::UpdateApplier(const InstallPlan &install_plan,
                             PrefsInterface* prefs,
                             BootControlInterface* boot_control,
                             HardwareInterface* hardware,
                             HttpFetcher *fetcher)
    : install_plan_action_(install_plan),
      download_action_(prefs, boot_control, hardware, nullptr, fetcher, true) {
  BondActions(&install_plan_action_, &download_action_);
}

ErrorCode UpdateApplier::Run() {
  ActionProcessor processor;
  processor.set_delegate(this);
  processor.EnqueueAction(&install_plan_action_);
  processor.EnqueueAction(&download_action_);

  loop_.SetAsCurrent();
  loop_.PostTask(
    FROM_HERE,
    base::Bind([](ActionProcessor* processor) { processor->StartProcessing(); },
               &processor)
  );
  loop_.Run();
  return error_code_;
}

void UpdateApplier::ProcessingDone(const ActionProcessor*, ErrorCode code) {
  error_code_ = code;
  loop_.BreakLoop();
}

}
