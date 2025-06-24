#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

# Input validation
if [ $# -ne 1 ]; then
  echo >&2 "Usage:"
  echo "  $0 <input-file>"
  exit 1
fi
INPUT_FILE=$1

# Simply grabs all the keys from a filters file
yq -o json 'keys' $INPUT_FILE | jq -c
