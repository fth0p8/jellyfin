FROM jellyfin/jellyfin:latest

# Install rclone
USER root
RUN apt-get update && \
    apt-get install -y rclone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory for Google Drive mount point
RUN mkdir -p /gdrive

# Copy scripts and config
COPY rclone.conf /root/.config/rclone/rclone.conf
COPY sync-script.sh /sync-script.sh
COPY start-all.sh /start-all.sh
RUN chmod +x /sync-script.sh /start-all.sh

# Expose Jellyfin port
EXPOSE 8096

# Override entrypoint and use our custom startup
ENTRYPOINT []
CMD ["/start-all.sh"]
