#!/bin/bash

echo "Starting Google Drive sync service..."

# Wait for network to be ready
sleep 5

# Initial sync
echo "Performing initial sync from Google Drive..."
rclone sync gdrive: /gdrive \
  --config /config/rclone/rclone.conf \
  --verbose \
  --transfers 4 \
  --checkers 8 \
  --fast-list

echo "Initial sync complete. Starting continuous sync loop..."

# Continuous sync every 15 minutes
while true; do
  echo "Syncing Google Drive at $(date)..."
  
  rclone sync gdrive: /gdrive \
    --config /config/rclone/rclone.conf \
    --transfers 4 \
    --checkers 8 \
    --fast-list \
    --verbose
  
  echo "Sync completed. Next sync in 15 minutes..."
  sleep 900  # 15 minutes
done
