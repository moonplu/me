#!/bin/bash

# Define the replacement link
replacement_link="https://raw.githubusercontent.com/moonplu/me/refs/heads/main/asset/nosig.m3u8"

# Temporary file to store the updated content
temp_file=$(mktemp)

# Read the extra.m3u file line by line
while IFS= read -r line; do
    # Check if the line is a URL (starts with http:// or https://)
    if [[ $line =~ ^https?:// ]]; then
        # Use curl to check if the link is working
        if curl --output /dev/null --silent --head --fail "$line"; then
            # Link is working, keep it as is
            echo "$line" >> "$temp_file"
        else
            # Link is not working, replace with the replacement link
            echo "$replacement_link" >> "$temp_file"
        fi
    else
        # Not a URL, keep the line as is
        echo "$line" >> "$temp_file"
    fi
done < "extra.m3u"

# Replace the original file with the updated content
mv "$temp_file" "extra.m3u"

echo "Link check and replacement completed."