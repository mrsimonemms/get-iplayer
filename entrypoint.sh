#!/bin/sh

set -e

# Download the file
get_iplayer --output="${TMP_OUTPUT_DIR}" --whitespace "${@}"

# Convert the filename
./iplayer-to-plex "${TMP_OUTPUT_DIR}"

# Copy it to the output directory
cp -Rf "${TMP_OUTPUT_DIR}"/* "${OUTPUT_DIR}"
