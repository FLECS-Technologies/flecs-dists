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

MOUNT=`mktemp -d`
run mkdir -p ${MOUNT}
run mount ${DEVICE}p3 ${MOUNT} || exit_cleanup 1
run mkdir -p ${MOUNT}/boot
run mount ${DEVICE}p2 ${MOUNT}/boot || exit_cleanup 1
run mkdir -p ${MOUNT}/efi
run mount ${DEVICE}p1 ${MOUNT}/efi || exit_cleanup 1
