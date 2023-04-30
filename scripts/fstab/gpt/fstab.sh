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

cp ${DIRNAME}/skel/etc/fstab ${MOUNT}/etc/fstab || exit_cleanup 1

echo "`lsblk -P -o UUID ${DEVICE}p3`    /       ext4    defaults,noatime    0   1" >>${MOUNT}/etc/fstab || exit_cleanup 1
echo "`lsblk -P -o UUID ${DEVICE}p2`    /boot   ext4    defaults,noatime    0   2" >>${MOUNT}/etc/fstab || exit_cleanup 1
echo "`lsblk -P -o UUID ${DEVICE}p1`    /efi    vfat    umask=0077          0   2" >>${MOUNT}/etc/fstab || exit_cleanup 1
