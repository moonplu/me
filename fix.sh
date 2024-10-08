#!/bin/bash

# Update the repository
git pull

# File path of the M3U playlist
M3U_FILE="index.m3u"
TEMP_FILE=$(mktemp)

# Fallback link for broken URLs
FALLBACK_URL="https://raw.githubusercontent.com/moonplu/me/refs/heads/main/asset/nosig.m3u8"

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
        
        # If the response is 200, write the line to the temporary file; otherwise, use the fallback URL
        if [ "$HTTP_RESPONSE" -eq 200 ]; then
            echo "$line" >> "$TEMP_FILE"
        else
            echo "$FALLBACK_URL" >> "$TEMP_FILE"
        fi
    else
        # Write non-URL lines (like #EXTINF) directly to the temp file
        echo "$line" >> "$TEMP_FILE"
    fi
done < "$M3U_FILE"

# Replace the original M3U file with the updated temporary file
mv "$TEMP_FILE" "$M3U_FILE"

echo "Updated $M3U_FILE. Broken links have been replaced with the fallback URL."

# Commit changes to the repository
git add "$M3U_FILE"
git commit -m "Updated m3u file: replaced broken links with fallback URL"
git push
