#!/bin/bash

# Prompt the user to select a CSV file
csv_file=$(find . -type f -name "*.csv" | fzf --prompt="Select a CSV file: ")

# Check if a file was selected
if [[ -z "$csv_file" ]]; then
  echo "No file selected. Exiting."
  exit 1
fi

# Prompt the user to select a column
column=$(head -n 1 "$csv_file" | tr ',' '\n' | nl -v 0 | fzf --prompt="Select a column: " | awk '{print $1}')

# Check if a column was selected
if [[ -z "$column" ]]; then
  echo "No column selected. Exiting."
  exit 1
fi

# Prompt the user if they want each value to be in single quotes
quote_values=$(echo -e "No\nYes" | fzf --prompt="Wrap each value in single quotes? ")

# Prompt the user if they want a newline after each comma
newline_after_comma=$(echo -e "No\nYes" | fzf --prompt="Add newline after each comma? ")

# Extract the selected column, optionally wrap in single quotes, and format with or without newlines
awk -v col="$column" -v quote="$quote_values" -v newline="$newline_after_comma" -F, '
NR > 1 {
  value = $col
  if (quote == "Yes") {
    value = "'"'"'" value "'"'"'"
  }
  if (newline == "Yes") {
    printf "%s,\n", value
  } else {
    printf "%s,", value
  }
}
END {
  if (newline != "Yes") {
    printf "\n"
  }
}
' "$csv_file" | pbcopy

echo "Column copied to clipboard."
