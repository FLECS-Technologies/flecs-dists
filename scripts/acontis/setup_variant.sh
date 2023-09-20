#!/bin/bash

if [ -z "${ACONTIS_BASE_URL}" ]; then
  echo "ACONTIS_BASE_URL not set" 1>&2
  exit 1
fi

source ${DIRNAME}/scripts/${VARIANT}/ec/ec-master.sh
source ${DIRNAME}/scripts/${VARIANT}/ec/ec-addons.sh
