#!/bin/bash
# Functions to be used by other scripts

# Detects a pattern in a file:
# - If found: ensures the line is exactly the passed line
# - If not found: inserts line at the end
ensure_line_in_file () {
  file="$1"
  pattern="$2"
  line="$3"
  # Use -F to match literal string, not regex
  if [[ ! $(grep -F "$pattern" "$file") ]]; then
    echo "$line" >> $file
  else
    sed -i "s%.*${pattern}.*%${line}%g" "$file"
  fi
}

