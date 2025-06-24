#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/_common.sh"

# Input validation
if [ $# -ne 4 ]; then
  echo >&2 "Usage:"
  echo "  $0 <changed-paths> <filter-file> <env-key> <default-env>"
  exit 1
fi
CHANGED_PATHS=$1
FILTER_FILE=$2
ENV_KEY=$3
DEFAULT_ENV=$4

# Convert our filters file into a lookup map, so we can map a path to
# a list of keys. Then map each change entry to it's corresponding keys and
# create the necessary matrix array structure
yq ea -o json "
  select(fileIndex == 1) as \$filters |
  \$filters = (
    \$filters |
    keys |
    map(. | capture(\"(?:(?<value>[\\\\w\\\\-_]+)\\\\|)?(?<key>[\\\\w\\\\-_\\\\/\\\\.]+)\")) |
    group_by(.key) |
    map({ (.[0].key): map(.value) }) |
    .[] as \$item ireduce ({}; . * \$item)
  ) |

  select(fileIndex == 0) |
  map(
    . as \$path |
    (\$filters[\$path] // [null]) |
    map({
      \"$ENV_KEY\": (. // \"$DEFAULT_ENV\"),
      \"path\": \$path
    })
  ) |
  flatten
  " $CHANGED_PATHS $FILTER_FILE | jq -c
