#!/bin/sh
set -e

# Check if the certificate does not exist yet
if [ ! -f /etc/ssl/certs/souel-bo.42.fr.cert ]; then
    echo "Creating secure SSL/TLS certificates for souel-bo.42.fr..."
    
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/certs/souel-bo.42.fr.key -out /etc/ssl/certs/souel-bo.42.fr.cert \
	-subj "/CN=souel-bo.42.fr"
        
    echo "Certificates successfully generated!"
fi

echo "Starting Nginx web server..."
exec "$@"