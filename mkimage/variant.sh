#!/bin/bash
# Copyright 2021-2023 FLECS Technologies GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# prepare image file
run rm -f "${BUILD_DIR}/${IMAGE_FILE}"
BASE_IMAGE=`find ${DIRNAME}/build -mindepth 1 -maxdepth 1 -type f -name "*_${DIST}_${SUITE}_generic_${PART_SCHEME}.img" | sort | tail -1`
if [ -z "${BASE_IMAGE}" ]; then
  echo "Could not find base image *_${DIST}_${SUITE}_generic_${PART_SCHEME} for variant ${VARIANT}" 1>&2
  exit 1
else
  echo "Found base image ${BASE_IMAGE} for variant ${VARIANT}"
fi

run cp "${BASE_IMAGE}" "${BUILD_DIR}/${IMAGE_FILE}"

# mount image file as loop device
DEVICE=`losetup --partscan --find --show "${BUILD_DIR}/${IMAGE_FILE}"`
[ $? -ne 0 ] && exit_cleanup 1

# mount partitions
source ${DIRNAME}/scripts/mount/${PART_SCHEME}/mount.sh

# setup variant-specific installation
source ${DIRNAME}/scripts/common/chroot_mount.sh
source ${DIRNAME}/scripts/common/copy_skel.sh
source ${DIRNAME}/scripts/common/copy_fs.sh
if [ -f "${DIRNAME}/scripts/${VARIANT}/setup_variant.sh" ]; then
  source ${DIRNAME}/scripts/${VARIANT}/setup_variant.sh
fi
