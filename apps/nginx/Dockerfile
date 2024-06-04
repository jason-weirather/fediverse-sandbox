FROM nginx:latest

# Copy the custom entrypoint script
COPY apps/nginx/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Make the script executable
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Copy the default Nginx configuration file
COPY nginx/conf.d /etc/nginx/conf.d

# Copy SSL certificates
COPY certs /etc/ssl/certs
COPY certs /etc/ssl/private

# Set the custom entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Expose the ports
EXPOSE 80
EXPOSE 443

