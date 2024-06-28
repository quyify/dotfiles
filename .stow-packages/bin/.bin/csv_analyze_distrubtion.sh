#!/bin/bash

# Function to prompt with fzf for file and column selection
prompt_with_fzf() {
	local file
	local column
	file=$(fzf --prompt="Select the CSV file: ")
	column=$(head -n 1 "$file" | tr -d '\r' | tr ',' '\n' | nl | fzf --prompt="Select the column to group by: " -d $'\t' | cut -f 2)
	FILE_PATH="$file"
	COLUMN_NAME="$column"
}

# If no arguments are provided, prompt using fzf
if [ "$#" -eq 0 ]; then
	if ! command -v fzf &>/dev/null; then
		echo "fzf could not be found. Please install fzf to use the interactive mode."
		exit 1
	fi
	prompt_with_fzf
	USE_LESS=1
else
	if [ "$#" -ne 2 ]; then
		echo "Usage: $0 <csv_file> <column_name>"
		exit 1
	fi
	FILE_PATH="$1"
	COLUMN_NAME="$2"
	USE_LESS=0
fi

# Determine the column number based on the column name
COLUMN_NUMBER=$(head -n 1 "$FILE_PATH" | tr -d '\r' | tr ',' '\n' | nl | grep -w "$COLUMN_NAME" | awk '{print $1}')
if [ -z "$COLUMN_NUMBER" ]; then
	echo "Column '$COLUMN_NAME' not found in the CSV file."
	exit 1
fi

# Extract the relevant column, sort, and count occurrences
# Ensure carriage returns are removed in processing stages.
awk -F, -v col="$COLUMN_NUMBER" 'NR>1 { gsub(/\r/, ""); print $col }' "$FILE_PATH" | sort -n | uniq -c >pods_jobs.txt

# Define variables
total_pods=0
most_jobs=0
most_jobs_pod=0
least_jobs=$(wc -l <pods_jobs.txt)
least_jobs_pod=0
total_jobs=0
jobs_per_pod=()
pods=()

# Read the pods_jobs.txt file and calculate required metrics
while read -r count pod_id; do
	pods+=("$(echo $pod_id | tr -d '\r')")
	jobs_per_pod+=("$(echo $count | tr -d '\r')")
	total_jobs=$((total_jobs + count))
	total_pods=$((total_pods + 1))
	if ((count > most_jobs)); then
		most_jobs=$count
		most_jobs_pod=$pod_id
	fi
	if ((count < least_jobs)); then
		least_jobs=$count
		least_jobs_pod=$pod_id
	fi
done <pods_jobs.txt

# Calculate average
average_jobs=$(echo "scale=2; $total_jobs / $total_pods" | bc)

# Calculate median
sorted_jobs=($(printf "%s\n" "${jobs_per_pod[@]}" | sort -n))
if ((total_pods % 2 == 0)); then
	mid=$((total_pods / 2))
	median_jobs=$(echo "scale=2; (${sorted_jobs[mid - 1]} + ${sorted_jobs[mid]}) / 2" | bc)
else
	mid=$((total_pods / 2))
	median_jobs=${sorted_jobs[mid]}
fi

# Prepare the report
REPORT=$(
	cat <<EOF

Total number of pods with jobs: $total_pods
Pod with the most jobs: Pod ID $most_jobs_pod with $most_jobs jobs
Pod with the least jobs: Pod ID $least_jobs_pod with $least_jobs jobs
Median number of jobs per pod: $median_jobs
Average number of jobs per pod: $average_jobs

Table of jobs per pod:
EOF
)
while read -r count pod_id; do
	REPORT+=$'\n'"Pod ID: $(echo $pod_id | tr -d '\r') has $(echo $count | tr -d '\r') jobs"
done <pods_jobs.txt

# Print the report
if [ "$USE_LESS" -eq 1 ]; then
	echo "$REPORT" | less
else
	echo "$REPORT"
fi

# Clean up
rm pods_jobs.txt
