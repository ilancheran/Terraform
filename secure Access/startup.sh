#!/bin/bash

# Update package repositories and install Apache (assuming you're on a Debian-based system).
sudo apt update
sudo apt install apache2 -y

# Create an HTML file with your "Welcome to my webpage" message.
cat <<EOL > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Welcome to My Webpage</title>
</head>
<body>
  <h1>Welcome to My Webpage</h1>
</body>
</html>
EOL

# Start the Apache web server.
sudo systemctl start apache2

# Enable Apache to start on boot.
sudo systemctl enable apache2

