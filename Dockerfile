FROM jellyfin/jellyfin:latest

# Install rclone and curl
USER root
RUN apt-get update && \
    apt-get install -y rclone curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /gdrive /root/.config/rclone

# Copy rclone config
COPY rclone.conf /root/.config/rclone/rclone.conf

# Create startup script that uses rclone's HTTP serve
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
    echo "ERROR: Cannot connect to Google Drive"\n\
    exit 1\n\
fi\n\
\n\
echo "Google Drive connected!"\n\
echo "Listing your Google Drive folders:"\n\
rclone lsd gdrive: 2>/dev/null || echo "Unable to list folders"\n\
\n\
echo "Starting rclone HTTP server for Google Drive..."\n\
rclone serve http gdrive: \\\n\
  --addr :8080 \\\n\
  --vfs-cache-mode full \\\n\
  --vfs-cache-max-size 20G \\\n\
  --vfs-cache-max-age 24h \\\n\
  --buffer-size 128M \\\n\
  --dir-cache-time 5m \\\n\
  --poll-interval 15s &\n\
\n\
echo "Waiting for HTTP server..."\n\
sleep 10\n\
\n\
for i in {1..30}; do\n\
  if curl -s http://localhost:8080 > /dev/null 2>&1; then\n\
    echo "HTTP server ready at http://localhost:8080"\n\
    break\n\
  fi\n\
  sleep 2\n\
done\n\
\n\
echo ""\n\
echo "========================================="\n\
echo "Your Google Drive is accessible at:"\n\
echo "http://localhost:8080"\n\
echo ""\n\
echo "In Jellyfin, add library paths like:"\n\
echo "http://localhost:8080/Movies"\n\
echo "http://localhost:8080/TV"\n\
echo "========================================="\n\
echo ""\n\
\n\
echo "Starting Jellyfin..."\n\
exec /jellyfin/jellyfin \\\n\
  --datadir /config \\\n\
  --cachedir /cache \\\n\
  --ffmpeg /usr/lib/jellyfin-ffmpeg/ffmpeg' > /start-stream.sh && \
chmod +x /start-stream.sh

# Expose ports
EXPOSE 8096

# Use streaming startup
ENTRYPOINT []
CMD ["/start-stream.sh"]
```

## 🚀 **What This Does:**

1. Lists your Google Drive folders in the logs
2. Shows you helpful messages about how to access them
3. Makes them available at `http://localhost:8080`

## 📋 **Your GitHub Repo:**
```
your-repo/
├── Dockerfile       ← Copy the content above
└── rclone.conf      ← Keep your existing one
