#!/bin/bash

# Function to URL decode a string
urldecode() {
  local url_encoded="${1//+/ }"
  printf '%b' "${url_encoded//%/\\x}"
}

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <url_encoded_string>"
  exit 1
fi

# Decode the input string
decoded_string=$(urldecode "$1")

# Print the decoded string
echo "Decoded string:"
echo "$decoded_string"
