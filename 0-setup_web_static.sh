#!/usr/bin/env bash
# This script sets up web servers for the deployment of web_static

#Install Nginx if not already installed
if ! dpkg -l | grep -q nginx; then
	sudo apt-get update
	sudo apt-get install -y nginx
fi

#Create necessary directories
sudo mkdir -p /data/web_static/releases/test/
sudo mkdir -p /data/web_static/shared/

#Create a fake HTML file
echo "<html>
<head>
</head>
<body>
	Holberton School
</body>
<html>" | sudo tee /data/web_static/releases/test/index.html
#Create a symbolic link, force remove if it already exists
sudo ln -sf /data/web_static/releases/test/ /data/web_static/current

# Give ownership of /data/ folder
sudo chown -R ubuntu:ubuntu /data/

# The Nginx configuration update
config="server {
	listen 80 default_server;
	listen [::]:80 default_server;

	root /var/www/html;
	index.html index.htm index.nginx-debian.html;

	server_name _;

	location / {
		try_files \$uri \$uri/ =404;
	}

	location /hbnb_static {
		alias /data/web_static/current;
		index index.html index.htm;
	}
}"

echo "$config" | sudo tee /etc/nginx/sites-available/default

# Restart Nginx
sudo service nginx restart

# Successful exit
exit 0
