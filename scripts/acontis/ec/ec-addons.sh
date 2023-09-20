#!/bin/bash

if [ -z "${ACONTIS_EC_ADDONS_ARCHIVE}" ]; then
  echo "ACONTIS_BASE_URL not set" 1>&2
  exit 1
fi

wget ${ACONTIS_BASE_URL}/${ACONTIS_EC_ADDONS_ARCHIVE}

ARCHIVE=`readlink -f ${ACONTIS_EC_ADDONS_ARCHIVE}`

TMPDIR="/tmp/`basename ${ARCHIVE}`.dir"
rm -rf ${TMPDIR}
mkdir -p ${TMPDIR}
tar -C ${TMPDIR} -xf "${ARCHIVE}"

mkdir -p ${MOUNT}/usr/local/bin
mkdir -p ${MOUNT}/usr/local/include
mkdir -p ${MOUNT}/usr/local/lib
mkdir -p ${MOUNT}/usr/local/share/doc/ec
mkdir -p ${MOUNT}/usr/local/src/ec/examples

mv ${TMPDIR}/Bin/Linux/x64/*      ${MOUNT}/usr/local/bin/
mv ${TMPDIR}/Examples/*           ${MOUNT}/usr/local/src/ec/examples/
mv ${TMPDIR}/SDK/INC/*            ${MOUNT}/usr/local/include/
mv ${TMPDIR}/SDK/LIB/Linux/x64/*  ${MOUNT}/usr/local/lib/

rm -rf ${TMPDIR}
rm ${ARCHIVE}
