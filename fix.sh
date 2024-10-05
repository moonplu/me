#!/bin/bash

git pull

# File path of the M3U playlist
M3U_FILE="index.m3u"
TEMP_FILE=$(mktemp)

# Check if the M3U file exists
if [ ! -f "$M3U_FILE" ]; then
    echo "M3U file not found: $M3U_FILE"
    exit 1
fi

# Read the M3U file and check each URL
while IFS= read -r line; do
    # Check if the line contains a URL
    if [[ $line == http* ]]; then
        # Check the URL and capture the HTTP response code
        HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$line")
        
        # If the response is 200, write to the temporary file; otherwise, skip it
        if [ "$HTTP_RESPONSE" -eq 200 ]; then
            # Write the previous line (#EXTINF) and the URL to the temp file
            echo "$PREV_LINE" >> "$TEMP_FILE"
            echo "$line" >> "$TEMP_FILE"
        fi
    else
        # Store the previous line to check against the next URL
        PREV_LINE="$line"
    fi
done < "$M3U_FILE"

# Replace the original M3U file with the cleaned temporary file
mv "$TEMP_FILE" "$M3U_FILE"

echo "Updated $M3U_FILE. Invalid links have been removed."


git add .
git commit -m "fixed"
git push
