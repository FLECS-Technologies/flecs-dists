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
run truncate -s ${IMAGE_SIZE} "${BUILD_DIR}/${IMAGE_FILE}"

# mount image file as loop device
DEVICE=`losetup --partscan --find --show "${BUILD_DIR}/${IMAGE_FILE}"`
[ $? -ne 0 ] && exit_cleanup 1

# create and format partitions
for script in `find ${DIRNAME}/scripts/fdisk/${PART_SCHEME}/ -mindepth 1 -maxdepth 1 -name "*.sh" | sort`; do
  source ${script} || exit_cleanup 1
done

# mount partitions
source ${DIRNAME}/scripts/mount/${PART_SCHEME}/mount.sh || exit_cleanup 1

# bootstrap
source ${DIRNAME}/scripts/${DIST}/bootstrap.sh

# setup bootstrapped installation
source ${DIRNAME}/scripts/common/chroot_mount.sh
source ${DIRNAME}/scripts/common/copy_skel.sh
source ${DIRNAME}/scripts/common/copy_fs.sh
source ${DIRNAME}/scripts/common/setup.sh
if [ -f "${DIRNAME}/scripts/${DIST}/setup.sh" ]; then
  source ${DIRNAME}/scripts/${DIST}/setup.sh
fi
source ${DIRNAME}/scripts/fstab/${PART_SCHEME}/fstab.sh

# install bootloader
source ${DIRNAME}/scripts/grub/${PART_SCHEME}/grub.sh

# install additional software
source ${DIRNAME}/scripts/common/swsetup.sh
source ${DIRNAME}/scripts/${DIST}/swsetup.sh
