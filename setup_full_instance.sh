#!/bin/bash
set -x
if [[ ! $EUID -eq 0 ]]; then
    echo "--this script requires root beer (sudo), exiting..."
fi

apt-add-repository ppa:webupd8team/java -y
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
apt update
apt install oracle-java8-installer -y
apt upgrade -y

# Install nginx.
apt install nginx -y
# Stop it, so we can reconfigure and boot later.
systemctl stop nginx

# Download and install elasticsearch
wget -q https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.4.1/elasticsearch-2.4.1.deb
dpkg -i elasticsearch*.deb
systemctl stop elasticsearch

# Download and install logstash
wget -q https://download.elastic.co/logstash/logstash/packages/debian/logstash-2.4.0_all.deb
dpkg -i logstash*.deb
systemctl stop logstash
# FIXME: `systemd` has some strange problems with the logstash 2.4.x deb on ubuntu 16.04. Because this isn't working
# properly, I'm trying to think of a workaround.
# Workaround 1: Fork of another logstash process.
# Workaround 2 (preferred for debugging): Start logstash at the end here, and then have this script echo stdout of the
# script.

# Download and install kibana
wget -q https://download.elastic.co/kibana/kibana/kibana-4.6.2-amd64.deb
dpkg -i kibana*.deb
systemctl stop kibana

# Whew! All packages installed. Time to customize.
# ===
# 1. Customize nginx. Dump custom kibana configuration, remove standard links.
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

# 2. Create `htpasswd.users` file similar to what apache would like/use.
# FIXME: There's another weird bug with nginx. Actually, I think I encountered a similar bug in my lifetime. I think
# it might be related to the `openssl passwd -apr1` command outputting a 0 on the end, creating an invalid passwd
# hash...! nginx gave me strange `crypt_r()` errors, but then when I reran the command to generate a new htpasswd
# file...it worked...
USERNAME="banjodemo"
HTPWFILE="/etc/nginx/htpasswd.users"
echo "--creating new user '$USERNAME' in '$HTPWFILE'..."
echo "$USERNAME:`openssl passwd -apr1`" | tee -a "$HTPWFILE"

# 3. We can now bring up nginx (has all configs), elasticsearch (takes a while).
systemctl start nginx
systemctl start elasticsearch
# Sleep to let elasticsearch start.
sleep 10

# 4. Bring up kibana. It will find elasticsearch (which it needs).
systemctl start kibana

# 5. Copy things to necessary places for logstash.
cp logstash/logstash-banjo.conf /opt/logstash/bin
cp logstash/elasticstack-nginx-template.json /opt/logstash/bin
# 6. Moment of truth! Run logstash, from the logstash directory.
cd /opt/logstash/bin
./logstash agent -f logstash-banjo.conf
