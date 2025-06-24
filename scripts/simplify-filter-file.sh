#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

# Input validation
if [ $# -ne 2 ]; then
  echo >&2 "Usage:"
  echo "  $0 <input-file> <output-file>"
  exit 1
fi
INPUT_FILE=$1
OUTPUT_FILE=$2

# Removes "environment" from keys (the part before the `|`), so that
#   Test|some/path: …
# Becomes
#   some/path: …
#
# It will also remove duplicate keys that might be generated after this
# operation
yq '
  with_entries(.key |= (. | sub("[\\w\\-_]*\\|", ""))) |
  pick(keys | unique)
  ' "$INPUT_FILE" > "$OUTPUT_FILE"
