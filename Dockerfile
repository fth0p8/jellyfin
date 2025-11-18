FROM jellyfin/jellyfin:latest

# Install rclone
USER root
RUN apt-get update && \
    apt-get install -y rclone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory
RUN mkdir -p /gdrive

# Copy config and startup script
COPY rclone.conf /root/.config/rclone/rclone.conf
COPY start-stream.sh /start-stream.sh
RUN chmod +x /start-stream.sh

# Expose ports
EXPOSE 8096 8080

# Use streaming startup
ENTRYPOINT []
CMD ["/start-stream.sh"]
