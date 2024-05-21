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
sudo tee /data/web_static/releases/test/index.html > /dev/null << EOF
<html>
	<head>
	</head>
	<body>
		Holberton School
	</body>
</html>
EOF

#Create a symbolic link, force remove if it already exists
rm -rf /data/web_static/current
sudo ln -sf /data/web_static/releases/test/ /data/web_static/current

# Give ownership of /data/ folder
sudo chown -R ubuntu:ubuntu /data/

# The Nginx configuration update
sudo tee /etc/nginx/sites-available/default >/dev/null <<EOF
server {
	listen 80;
	listen [::]:80 default_server;

	server_name _;
	add_header X-Served-By "${HOSTNAME}";
	location /redirect_me {
		return 301 https://www.youtube.com/watch?v=QH2-TGUlwu4;
	}
	location @404 {
		return "Ceci n'est pas une page.";
	}

	location /hbnb_static/current/ {
		alias /data/web_static/current/;
	}
	
	root /var/www/html;
	error_page 404 = @404;
}
EOF

sudo service nginx restart
