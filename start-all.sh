#!/bin/bash

echo "Starting Jellyfin with Google Drive sync..."

# Start rclone sync in background
/sync-script.sh &

echo "rclone sync started in background"

# Start Jellyfin in foreground
echo "Starting Jellyfin..."
exec /jellyfin/jellyfin \
  --datadir /config \
  --cachedir /cache \
  --ffmpeg /usr/lib/jellyfin-ffmpeg/ffmpeg
