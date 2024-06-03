#!/bin/bash

# Get the latest modified files in /root
latest_files=$(find /root -type f -printf '%T@ %p\n' | sort -n | tail -5)

# Display the dates of the latest modified files
echo "Latest modified files in /root:"
echo "$latest_files" | while read -r file; do
    file_date=$(echo "$file" | cut -d' ' -f1)
    file_name=$(echo "$file" | cut -d' ' -f2-)
    echo "$(date -d @"$file_date") - $file_name"
done