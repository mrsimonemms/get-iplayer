#!/bin/sh

set -e

get_iplayer --output="${TMP_OUTPUT_DIR}" $@

cp -Rf ${TMP_OUTPUT_DIR}/* ${OUTPUT_DIR}
