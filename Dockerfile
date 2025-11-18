FROM jellyfin/jellyfin:latest

# Install rclone (no fuse needed)
USER root
RUN apt-get update && \
    apt-get install -y rclone curl supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /gdrive /var/log/supervisor

# Copy configuration files
COPY rclone.conf /config/rclone/rclone.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY sync-script.sh /sync-script.sh
RUN chmod +x /sync-script.sh

# Expose Jellyfin port
EXPOSE 8096

# Use supervisor to manage both services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
