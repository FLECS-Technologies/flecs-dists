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

first_login() {
  systemctl disable --now flecs-init

  echo "Please change your root password now"
  passwd || logout

  # 20_rootpw.sh
  rm /etc/issue
  mv /etc/issue.orig /etc/issue

  sed -i 's,^Banner.*,#Banner none,g' /etc/ssh/sshd_config
  rm /etc/ssh/sshd_banner

  # 30_first-login.sh
  sed -i '/flecs-init/d' /etc/bash.bashrc
}

case ${1} in
  run)
    DIRNAME=`dirname $(readlink -f ${0})`
    find ${DIRNAME}/../scripts/ -mindepth 1 -maxdepth 1 -name "*.sh" -exec bash -c {} \;
    ;;
  disable)
    first_login
    ;;
esac
