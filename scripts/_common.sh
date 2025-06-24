#!/usr/bin/env bash

# Fail on first error
set -euo pipefail

# Verify tools installed
if ! [ -x "$(command -v jq)" ]; then
  echo >&2 'Error: jq is not installed.'
  exit 1
fi
if ! [ -x "$(command -v yq)" ]; then
  echo >&2 'Error: jq is not installed.'
  exit 1
fi
