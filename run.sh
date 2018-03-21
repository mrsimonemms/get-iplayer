#!/bin/sh

set -e

PID="$1"

if [ -z "$PID" ]; then
  echo "Please set a programme ID as argument 1"
  exit 1
fi

get_iplayer --nocopyright --subdir --whitespace --output="${OUTPUT_DIR}" --pid="$PID"
