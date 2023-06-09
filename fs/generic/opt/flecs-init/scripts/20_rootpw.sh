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

echo -n "Changing root password... "

if [ ! -f /etc/issue.orig ]; then
  mv /etc/issue /etc/issue.orig
  exit_if_failed "Could not move /etc/issue to /etc/issue.orig"
fi

PASSWORD=`mktemp -u XXXXXXXX`

echo "root:${PASSWORD}" | chpasswd
exit_if_failed "Could not change root password"

cat /etc/issue.orig <(echo "Your root password is '${PASSWORD}'") >/etc/issue <(echo)
exit_if_failed "Could not update login message"

cat <(echo "Your root password is '${PASSWORD}'") <(echo) >/etc/ssh/sshd_banner
exit_if_failed "Could not write SSH banner"
sed -i 's,^#Banner.*,Banner /etc/ssh/sshd_banner,g' /etc/ssh/sshd_config
exit_if_failed "Could not update sshd_config"
systemctl restart ssh
exit_if_failed "Could not restart SSH server"

source ${DIRNAME}/common/done.sh
