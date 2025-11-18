#!/bin/bash

echo "Starting Jellyfin with Google Drive sync..."

# Verify rclone config exists
if [ ! -f /root/.config/rclone/rclone.conf ]; then
    echo "ERROR: rclone.conf not found!"
    exit 1
fi

# Test rclone connection
echo "Testing Google Drive connection..."
if ! rclone lsd gdrive: --max-depth 1 2>/dev/null; then
    echo "ERROR: Cannot connect to Google Drive. Check your rclone.conf"
    exit 1
fi

echo "Google Drive connection successful!"

# Start rclone sync in background
/sync-script.sh &
SYNC_PID=$!

echo "rclone sync started in background (PID: $SYNC_PID)"

# Give sync a moment to start
sleep 2

# Start Jellyfin in foreground
echo "Starting Jellyfin..."
exec /jellyfin/jellyfin \
  --datadir /config \
  --cachedir /cache \
  --ffmpeg /usr/lib/jellyfin-ffmpeg/ffmpeg
