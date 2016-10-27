#!/bin/bash
if [[ ! $EUID -eq 0 ]]; then
    echo "--this script requires root beer (sudo), exiting..."
fi
cat <<KIBANA_CONF >/etc/nginx/sites-available/kibana
server {
	listen 80;
	server_name banjodemo.ignisphaseone.com;
	auth_basic "Restricted Access";
	auth_basic_user_file /etc/nginx/htpasswd.users;
	
	location / {
		proxy_pass http://localhost:5601;
		proxy_http_version 1.1;
		proxy_set_header Upgrade \$http_upgrade;
		proxy_set_header Connection 'upgrade';
		proxy_set_header Host \$host;
		proxy_cache_bypass \$http_upgrade;
	}
}
KIBANA_CONF

rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/kibana /etc/nginx/sites-enabled/kibana
