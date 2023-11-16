#!/bin/bash

# Update and install Apache
sudo apt-get update
sudo apt-get install -y apache2

# Generate a self-signed SSL certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Configure Apache
sudo a2enmod ssl
sudo a2ensite default-ssl

# Update the Apache SSL configuration
sudo sed -i 's/SSLCertificateFile.*/SSLCertificateFile \/etc\/ssl\/certs\/selfsigned.crt/' /etc/apache2/sites-available/default-ssl.conf
sudo sed -i 's/SSLCertificateKeyFile.*/SSLCertificateKeyFile \/etc\/ssl\/private\/selfsigned.key/' /etc/apache2/sites-available/default-ssl.conf

# Open port 443 in the firewall
sudo ufw allow 443/tcp

# Restart Apache
sudo service apache2 restart