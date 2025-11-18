FROM jellyfin/jellyfin:latest

# Install rclone
USER root
RUN apt-get update && \
    apt-get install -y rclone curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory
RUN mkdir -p /gdrive /root/.config/rclone

# Copy rclone config
COPY rclone.conf /root/.config/rclone/rclone.conf

# Create startup script directly in Dockerfile to avoid line ending issues
RUN echo '#!/bin/bash\n\
echo "Starting Jellyfin with Google Drive streaming..."\n\
\n\
if [ ! -f /root/.config/rclone/rclone.conf ]; then\n\
    echo "ERROR: rclone.conf not found!"\n\
    exit 1\n\
fi\n\
\n\
echo "Testing Google Drive connection..."\n\
if ! rclone lsd gdrive: --max-depth 1 2>/dev/null; then\n\
    echo "ERROR: Cannot connect to Google Drive. Check your rclone.conf"\n\
    exit 1\n\
fi\n\
\n\
echo "Google Drive connection successful!"\n\
\n\
echo "Starting rclone WebDAV server for Google Drive streaming..."\n\
rclone serve webdav gdrive: \\\n\
  --addr :8080 \\\n\
  --vfs-cache-mode full \\\n\
  --vfs-cache-max-size 20G \\\n\
  --vfs-cache-max-age 24h \\\n\
  --buffer-size 128M \\\n\
  --dir-cache-time 5m \\\n\
  --poll-interval 15s \\\n\
  --no-checksum \\\n\
  --no-modtime \\\n\
  --use-server-modtime &\n\
\n\
RCLONE_PID=$!\n\
echo "rclone WebDAV server started (PID: $RCLONE_PID)"\n\
\n\
echo "Waiting for rclone server to be ready..."\n\
sleep 10\n\
\n\
for i in {1..30}; do\n\
  if curl -s http://localhost:8080 > /dev/null 2>&1; then\n\
    echo "rclone WebDAV server is ready!"\n\
    break\n\
  fi\n\
  echo "Waiting for rclone... ($i/30)"\n\
  sleep 2\n\
done\n\
\n\
echo "Starting Jellyfin..."\n\
exec /jellyfin/jellyfin \\\n\
  --datadir /config \\\n\
  --cachedir /cache \\\n\
  --ffmpeg /usr/lib/jellyfin-ffmpeg/ffmpeg' > /start-stream.sh && \
chmod +x /start-stream.sh

# Expose ports
EXPOSE 8096 8080

# Use streaming startup
ENTRYPOINT []
CMD ["/start-stream.sh"]
