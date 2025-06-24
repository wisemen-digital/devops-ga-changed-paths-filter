#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

# Input validation
if [ $# -ne 1 ]; then
  echo >&2 "Usage:"
  echo "  $0 \"<manual-input>\""
  exit 1
fi
MANUAL_INPUT="$1"

# Split input on comma's, generate JSON array
echo "$MANUAL_INPUT" | jq 'split(",")' -Rc
