FROM vacation/snac:latest

COPY ./certs/myCA.pem /usr/local/share/ca-certificates/myCA.crt
RUN update-ca-certificates

# Install jq
RUN apk -U --no-progress --no-cache add jq

# Copy the custom entrypoint script
COPY apps/snac1/docker-entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the script executable
RUN chmod +x /usr/local/bin/entrypoint.sh


# Set the custom entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Expose the port
EXPOSE 8001

