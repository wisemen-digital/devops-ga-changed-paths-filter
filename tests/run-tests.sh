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

# 
# Helpers
#

function test_cmd() {
  NAME=$1
  EXPECTED=$2
  shift; shift

  echo -n "### Testing '$NAME'… "
  OUTPUT=`$@`

  if [ "$OUTPUT" = "$EXPECTED" ]; then
    echo "Success!"
  else
    echo "Failed!"
    cat << EOF
- Output:
$OUTPUT
- Expected:
$EXPECTED
EOF
    exit 1
  fi
}

function test_cmd_with_diff() {
  NAME=$1
  EXPECTED=$2
  shift; shift

  echo -n "### Testing '$NAME'… "
  tmpfile=$(mktemp /tmp/devops-ga-changed-paths-filter.XXXXXX)
  $@ $tmpfile

  if diff_output=$(diff $tmpfile $EXPECTED); then
    echo "Success!"
    rm $tmpfile
  else
    echo "Error!"
    echo "$diff_output"
    rm $tmpfile
  fi
}

#
# Tests
#

# Simplify filter file
test_cmd_with_diff \
  'Simplify filter file' \
  ./tests/simple-filters.yaml \
  ./scripts/simplify-filter-file.sh tests/full-filters.yaml

# Generate all
test_cmd \
  'Generate all' \
  '["k8s/network","k8s/environments/development","k8s/environments/qa","k8s/environments/staging","k8s/environments/sandbox","k8s/environments/production","k8s/shared/signoz-otel-collector"]' \
  ./scripts/generate-all-keys.sh tests/simple-filters.yaml

# Process manual keys
test_cmd \
  'Process manual keys' \
  '["hello/world","foo","bar/baz"]' \
  ./scripts/process-manual-keys.sh "hello/world,foo,bar/baz"

# Verify matrix generation (all)
CHANGED_PATHS='["k8s/network","k8s/environments/development","k8s/environments/qa","k8s/environments/staging","k8s/environments/sandbox","k8s/environments/production","k8s/shared/signoz-otel-collector"]'
test_cmd \
  'Matrix generation (all)' \
  '[{"environment":"Default","path":"k8s/network"},{"environment":"Sandbox","path":"k8s/network"},{"environment":"Production","path":"k8s/network"},{"environment":"Development","path":"k8s/environments/development"},{"environment":"QA","path":"k8s/environments/qa"},{"environment":"Staging","path":"k8s/environments/staging"},{"environment":"Sandbox","path":"k8s/environments/sandbox"},{"environment":"Production","path":"k8s/environments/production"},{"environment":"Default","path":"k8s/shared/signoz-otel-collector"},{"environment":"Sandbox","path":"k8s/shared/signoz-otel-collector"},{"environment":"Production","path":"k8s/shared/signoz-otel-collector"}]' \
  ./scripts/generate-matrix.sh <(echo $CHANGED_PATHS) tests/full-filters.yaml environment Default

# Verify matrix generation (partial)
CHANGED_PATHS='["k8s/network","k8s/environments/development"]'
test_cmd \
  'Matrix generation (partial)' \
  '[{"environment":"Default","path":"k8s/network"},{"environment":"Sandbox","path":"k8s/network"},{"environment":"Production","path":"k8s/network"},{"environment":"Development","path":"k8s/environments/development"}]' \
  ./scripts/generate-matrix.sh <(echo $CHANGED_PATHS) tests/full-filters.yaml environment Default
