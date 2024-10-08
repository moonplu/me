#!/bin/bash

git pull

# File path of the M3U playlist
M3U_FILE="extra.m3u"
TEMP_FILE=$(mktemp)
REPLACEMENT_URL="https://raw.githubusercontent.com/moonplu/me/refs/heads/main/asset/nosig.m3u8"

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
        
        # If the response is 200, write to the temporary file; otherwise, use the replacement URL
        if [ "$HTTP_RESPONSE" -eq 200 ]; then
            echo "$PREV_LINE" >> "$TEMP_FILE"
            echo "$line" >> "$TEMP_FILE"
        else
            echo "$PREV_LINE" >> "$TEMP_FILE"
            echo "$REPLACEMENT_URL" >> "$TEMP_FILE"
        fi
    else
        # Store the previous line to check against the next URL
        PREV_LINE="$line"
        # Write non-URL lines directly to the temp file
        echo "$line" >> "$TEMP_FILE"
    fi
done < "$M3U_FILE"

# Replace the original M3U file with the updated temporary file
mv "$TEMP_FILE" "$M3U_FILE"

echo "Updated $M3U_FILE. Invalid links have been replaced with the specified URL."

git add .
git commit -m "replaced invalid links with nosig.m3u8"
git push