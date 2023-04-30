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

exit_cleanup() {
  if [ ! -z "${MOUNT}" ]; then
    umount -R ${MOUNT}
    rm -r ${MOUNT}
  fi
  if [ ! -z "${DEVICE}" ]; then
    losetup -d ${DEVICE}
  fi
  exit ${1}
}

DIRNAME=$(dirname $(readlink -f ${0}))
SCRIPTNAME=$(basename $(readlink -f ${0}))

print_usage() {
  echo "Usage: ${SCRIPTNAME} --dist <dist> --suite <suite> (--variant <generic>)"
  echo -ne "Valid targets are:\n    "

  for dist in `find ${DIRNAME}/dists -mindepth 1 -maxdepth 1 -type f | sort`; do
    DISTS="${DISTS}* $(basename ${dist})\n    "
  done
  DISTS=${DISTS::-2}
  echo -e "${DISTS}"
}

check_required_arg() {
  if [ -z "${2}" ] || [[ ${2} == --* ]]; then
    echo "Invalid value '${2}' for argument '${1}'" 1>&2
    exit 1
  fi
}

. ${DIRNAME}/scripts/common/common.sh

while [ ! -z "${1}" ]; do
  case ${1} in
    --dist)
      check_required_arg ${1} ${2}
      DIST="${2}"
      shift
      shift
      ;;
    --suite)
      check_required_arg ${1} ${2}
      SUITE="${2}"
      shift
      shift
      ;;
    --variant)
      check_required_arg ${1} ${2}
      VARIANT="${2}"
      shift
      shift
      ;;
    *)
      echo "Warning: skipping unrecognized command line option ${1}" 1>&2
      shift
      ;;
  esac
done

# distribution to build
if [ -z "${DIST}" ]; then
  echo "No DIST specified" 1>&2
  print_usage
  exit 1
fi
if [ -z "${SUITE}" ]; then
  echo "No SUITE specified" 1>&2
  print_usage
  exit 1
fi
[ -z "${VARIANT}" ] && VARIANT="generic"

# target system properties
[ -z "${CHARSET}" ] && CHARSET="UTF-8"
[ -z "${HOST}"] && HOST="flecs"
[ -z "${IMAGE_SIZE}" ] && IMAGE_SIZE=4294967296
[ -z "${INIT_SYSTEM}" ] && INIT_SYSTEM="systemd"
[ -z "${LOCALE}" ] && LOCALE="en_US.UTF-8"
[ -z "${PART_SCHEME}" ] && PART_SCHEME="gpt"
[ -z "${IMAGE_FILE}" ] && IMAGE_FILE="`date +%Y%m%d`_${DIST}_${SUITE}_${VARIANT}_${PART_SCHEME}.img"

# validity checks
if [ ! -f "${DIRNAME}/dists/${DIST}_${SUITE}_${VARIANT}" ]; then
  print_usage
  exit 1
fi
if [ "${INIT_SYSTEM}" != "systemd" ]; then
  echo "Invalid INIT_SYSTEM specified: (systemd)" 1>&2
  exit 1
fi
if [ "${PART_SCHEME}" != "gpt" ] && [ "${PART_SCHEME}" != "mbr" ]; then
  echo "Invalid PART_SCHEME specified: (gpt|mbr)" 1>&2
  exit 1
fi

BUILD_DIR="${DIRNAME}/build"
run mkdir -p "${BUILD_DIR}"

source ${DIRNAME}/dists/${DIST}_${SUITE}_${VARIANT}

if [ "${VARIANT}" == "generic" ]; then
  source ${DIRNAME}/mkimage/generic.sh
else
  source ${DIRNAME}/mkimage/variant.sh
fi

echo "Cleaning up..."
exit_cleanup 0
