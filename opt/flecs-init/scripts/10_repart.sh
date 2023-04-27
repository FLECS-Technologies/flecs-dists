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

DIRNAME=`dirname $(readlink -f ${0})`
source ${DIRNAME}/common/vars.sh

FS=`LANG=C mount | grep "on / " | sed 's/ .*//'`
DEVICE=`echo -n ${FS} | sed 's/p\?[0-9]//'`

echo -n "Searching root partition... "
ROOT_PART=`echo -n ${FS} | grep -oE "[0-9]+"`
exit_if_failed "Could not determine root partition number on ${DEVICE}"

echo "Detected / on ${FS} (${DEVICE}, partition ${ROOT_PART})"

echo -n "Determining root device size... "
if [ -z "${DEVICE_SIZE}" ]; then
  DEVICE_SIZE=`fdisk -l ${DEVICE} | sed -n -r 's#^Disk.+, ([0-9]+) bytes,.*#\1#p'`
  exit_if_failed "Could not determine size of ${DEVICE}"
fi

echo -n "Determining total system memory... "
if [ -z "${MEM_TOTAL}" ];then
  MEM_TOTAL=`sed -n -r 's#^MemTotal:[[:space:]]+([0-9]+).*#\1#p' /proc/meminfo`
  exit_if_failed "Could not determine total memory"
fi

echo -n "Calculating swap size... "
SWAP_MAX=$((8 * 1024 * 1024 * 1024))
# 2 * RAM for <= 2GiB
if ((${MEM_TOTAL} <= 2097152)); then
  SWAP_REC=$((${MEM_TOTAL} * 2 * 1024))
# 1.5 * RAM for <= 4GiB
elif ((${MEM_TOTAL} <= 4194304)); then
  SWAP_REC=$((${MEM_TOTAL} * 3 / 2 * 1024))
# 1 * RAM otherwise
else
  SWAP_REC=$((${MEM_TOTAL} * 1024))
fi
# cap at 8GiB
SWAP_REC=$((SWAP_REC<=SWAP_MAX ? SWAP_REC : SWAP_MAX))

# cap at 10% of root device
SWAP_MAX=$((${DEVICE_SIZE} / 10))
if ((${DEVICE_SIZE} <= 8589934592)); then
  SWAP_REC=0
else
  SWAP_REC=$((SWAP_REC < SWAP_MAX ? SWAP_REC : SWAP_MAX))
fi
exit_if_failed "Could not calculate swap size"

echo "Reserving $((SWAP_REC / 1024)) of $((DEVICE_SIZE / 1024)) as swap space"

echo -n "Resizing root partition... "

# Automated input to fdisk - make sure to keep empty lines!
echo "
d
${ROOT_PART}
n


-$((SWAP_REC / 1024))K
n



t
$((ROOT_PART + 1))
19
w
"| fdisk ${DEVICE} >/dev/null 2>&1

exit_if_failed "Could not resize root partition"

echo -n "Growing file system... "

resize2fs ${FS} >/dev/null 2>&1

exit_if_failed "Could not grow root file system"

echo -n "Formatting swap... "
mkswap `echo ${FS} | sed "s/${ROOT_PART}/$((ROOT_PART + 1))/g"`
echo -n "Enabling swap... "
swapon /dev/sda4
exit_if_failed "Could not enable swap"

source ${DIRNAME}/common/done.sh
