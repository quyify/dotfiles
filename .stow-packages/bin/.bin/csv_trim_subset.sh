#!/bin/bash

# Function to determine the smaller and larger files
determine_files() {
	local file1="$1"
	local file2="$2"

	local count1 count2
	count1=$(($(wc -l <"$file1") - 1)) # Exclude header
	count2=$(($(wc -l <"$file2") - 1)) # Exclude header

	if [ "$count1" -gt "$count2" ]; then
		set_file="$file1"
		subset_file="$file2"
	else
		set_file="$file2"
		subset_file="$file1"
	fi
}

# Function to trim whitespace from a CSV file
trim_whitespace() {
	local file="$1"
	[ ! -f "$file" ] && {
		echo "File not found!"
		return 1
	}

	local temp_file
	temp_file=$(mktemp)

	awk 'BEGIN { FS = OFS = "," } {
        for (i = 1; i <= NF; i++) {
            gsub(/^[ \t]+|[ \t]+$/, "", $i) # Trim leading/trailing whitespace
        }
        print
    }' "$file" >"$temp_file"

	mv "$temp_file" "$file"
	echo "Whitespace trimmed for file: $file"
}

# Function to prompt for file deletion using fzf
prompt_delete() {
	local file="$1"
	local options=("No" "Yes")

	echo "Do you want to delete the original file ($file)?"
	echo ""
	local selection
	selection=$(printf "%s\n" "${options[@]}" | fzf --prompt="Select an option: " --height 10 --layout=reverse --border)

	if [[ "$selection" == "Yes" ]]; then
		rm "$file"
		echo "**** Deleted original file:"
	else
		echo "**** Kept original file:"
	fi
	echo "$file"
	echo ""
}

# Function to get column index by name
get_column_index() {
	local header="$1"
	local column_name="$2"

	awk -v column="$column_name" 'BEGIN { FS = OFS = "," }
    {
        for (i=1; i<=NF; i++) {
            if ($i == column) {
                print i
                exit
            }
        }
    }' <<<"$header"
}

# Function to trim subset from set
trim_subset() {
	local set_file="$1"
	local subset_file="$2"
	local column_name="$3"

	trim_whitespace "$subset_file"
	trim_whitespace "$set_file"

	local set_basename trimmed_name output_file
	set_basename=$(basename "$set_file")
	trimmed_name="${set_basename%.csv}"
	output_file="${trimmed_name}.trimmed.tmp.csv"

	local header_set header_subset column_index_set column_index_subset

	header_set=$(head -n 1 "$set_file")
	header_subset=$(head -n 1 "$subset_file")

	column_index_set=$(get_column_index "$header_set" "$column_name")
	column_index_subset=$(get_column_index "$header_subset" "$column_name")

	if [[ -z "$column_index_set" || -z "$column_index_subset" ]]; then
		echo "One of the files does not have the column: $column_name."
		exit 1
	fi

	# Extract the specified column from subset_file to create a set of IDs
	awk -v FS=',' -v col_idx="$column_index_subset" 'NR > 1 { print $col_idx }' "$subset_file" >subset_ids.txt

	# Filter the set_file to exclude matching IDs from subset_ids.txt
	# Print header and then filter rows
	awk -v FS=',' -v col_idx="$column_index_set" 'FNR==NR { ids[$1]; next }
    FNR==1 {print; next}
    !($col_idx in ids)' subset_ids.txt "$set_file" >"$output_file"

	# Count the lines without the header to name the output file correctly
	local set_line_count
	set_line_count=$(($(wc -l <"$output_file") - 1))

	local set_output_file
	set_output_file="${trimmed_name}.trimmed.${set_line_count}.csv"
	mv "$output_file" "$set_output_file"

	# Filter the set_file to include only matching IDs
	awk -v FS=',' -v col_idx="$column_index_set" 'FNR==NR { ids[$1]; next }
    FNR==1 {print; next}
    $col_idx in ids' subset_ids.txt "$set_file" >"$output_file"

	# Count the lines excluding the header
	local subset_line_count
	subset_line_count=$(($(wc -l <"$output_file") - 1))

	local subset_output_file
	subset_output_file="${trimmed_name}.trimmed.$((subset_line_count)).csv"
	mv "$output_file" "$subset_output_file"

	rm subset_ids.txt

	echo -e "\n**** Created new files:"
	echo "$set_output_file"
	echo "$subset_output_file"
	echo ""

	prompt_delete "$set_file"
	prompt_delete "$subset_file"
}

# Interactive mode to select column using fzf
select_column_interactively() {
	local file="$1"
	local header

	header=$(head -n 1 "$file")
	if [ -z "$header" ]; then
		echo "File is empty or does not contain a header row."
		exit 1
	fi

	local columns=($(echo "$header" | awk -F, '{for (i=1; i<=NF; i++) print $i}'))
	local selected_column

	selected_column=$(printf "%s\n" "${columns[@]}" | fzf --prompt="Select the column to match: ")
	if [ -z "$selected_column" ]; then
		echo "No column selected."
		exit 1
	fi

	echo "$selected_column"
}

# Main logic
if [ "$#" -eq 3 ]; then
	if [ ! -f "$1" ] || [ ! -f "$2" ]; then
		echo "Both files must exist."
		exit 1
	fi

	determine_files "$1" "$2"
	trim_subset "$set_file" "$subset_file" "$3"
	exit 0
fi

if [ "$#" -eq 0 ]; then
	set -e
	echo "Select the larger set file:"
	larger_set_file=$(find . -name '*.csv' | fzf --prompt="Select the larger set file: ") || {
		echo "No file selected."
		exit 1
	}

	echo "Select the smaller set file (subset):"
	smaller_subset_file=$(find . -name '*.csv' | fzf --prompt="Select the smaller set file (subset): ") || {
		echo "No file selected."
		exit 1
	}
	set +e

	determine_files "$larger_set_file" "$smaller_subset_file"

	selected_column=$(select_column_interactively "$subset_file")

	trim_subset "$set_file" "$subset_file" "$selected_column"
	exit 0
fi

echo "Usage: $0 <set.csv> <subset.csv> <column_name>"
echo "Or run without arguments for interactive mode."
exit 1
