#!/bin/bash
apt-get update
apt-get install apache2 -y
ln -sr /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/headers.load
echo "<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            background-color: green;
            margin: 0;
            padding: 0;
        }
    </style>
</head>
<body>
</body>
</html>
" > /var/www/html/index.html
lb_weight=$(curl -H "Metadata-Flavor:Google" http://169.254.169.254/computeMetadata/v1/instance/attributes/load-balancing-weight)
echo "Header set X-Load-Balancing-Endpoint-Weight \"$lb_weight\"" > /etc/apache2/conf-enabled/headers.conf
systemctl restart apache2


