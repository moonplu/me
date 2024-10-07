#!/bin/bash

# Check if a channel ID was provided
if [ $# -eq 0 ]; then
    echo "Please provide a YouTube channel ID as an argument."
    exit 1
fi

# Set the channel ID
CHANNEL_ID="$1"

# Construct the live stream URL
LIVE_URL="https://www.youtube.com/channel/$CHANNEL_ID/live"

# Use yt-dlp to extract the m3u8 link
M3U8_LINK=$(yt-dlp -g "$LIVE_URL" 2>/dev/null)

# Check if an m3u8 link was found
if [ -n "$M3U8_LINK" ]; then
    echo "Live stream m3u8 link:"
    echo "$M3U8_LINK"
else
    echo "No live stream found for the given channel ID."
fi
