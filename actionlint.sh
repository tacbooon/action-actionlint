#!/bin/bash

set -euo pipefail

# Some action inputs accept both JSON array and a string.
# This function converts them to line separated strings.
parse_json_or_string_to_array() {
  local json_or_string="$1"
  if [[ "$json_or_string" =~ ^\{ ]]; then
    echo "Error: Input is an object, but expected an array or string." >&2
    exit 1
  elif [[ "$json_or_string" =~ ^\[ ]]; then
    echo "${json_or_string}" | jq -r '.[]'
  else
    echo "${json_or_string}"
  fi
}

# Arguments for actionlint
ARGS=()

# Enable color output
ARGS+=("--color")

# Enable verbose logs
ARGS+=("--verbose")

# Add input files to ARGS. Glob patterns are expanded here.
readarray -t INPUT_FILES < <(parse_json_or_string_to_array "${1:-[]}")
for pattern in "${INPUT_FILES[@]}"; do
  for file in $pattern; do
    ARGS+=("$file")
  done
done

# Run actionlint
actionlint "${ARGS[@]}"
