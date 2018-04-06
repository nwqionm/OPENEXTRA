#!/bin/sh

#Requirement
if [ ! -e /usr/bin/curl ]; then
    apt-get -y update && apt-get -y upgrade
        apt-get -y install curl
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(curl -4 icanhazip.com)
if [ $MYIP = "" ]; then
   MYIP=`ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1`;
fi
MYIP2="s/xxxxxxxxx/$MYIP/g";



# go to root
cd

# update
apt-get update -y
apt-get install build-essential expect -y
apt-get install -y mysql-server
mysql_secure_installation
chown -R mysql:mysql /var/lib/mysql/
chmod -R 755 /var/lib/mysql/

# install nginx
apt-get install -y nginx php5 php5-fpm php5-cli php5-mysql php5-mcrypt
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old

cat > /etc/nginx/nginx.conf <<END
user www-data;
worker_processes 2;
pid /var/run/nginx.pid;
events {
	multi_accept on;
        worker_connections 1024;
}
http {
	autoindex on;
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        server_tokens off;
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
        client_max_body_size 32M;
	client_header_buffer_size 8m;
	large_client_header_buffers 8 8m;
	fastcgi_buffer_size 8m;
	fastcgi_buffers 8 8m;
	fastcgi_read_timeout 600;
        include /etc/nginx/conf.d/*.conf;
}
END

cat > /etc/nginx/conf.d/vps.conf <<END
server {
    listen       85;
    server_name  127.0.0.1 localhost;
    access_log /var/log/nginx/vps-access.log;
    error_log /var/log/nginx/vps-error.log error;
    root   /home/vps/public_html;
    location / {
        index  index.html index.htm index.php;
	try_files $uri $uri/ /index.php?$args;
    }
    location ~ \.php$ {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
END

sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf

# useradd
useradd -m web
mkdir -p /home/web/public_html
echo "<?php phpinfo() ?>" > /home/web/public_html/info.php
chown -R www-data:www-data /home/web/public_html
chmod -R g+rw /home/web/public_html
service php5-fpm restart
service nginx restart

# apt unzip
apt-get -y install zip unzip
cd /home/web/public_html
wget https://github.com/nwqionm/OPENEXTRA/raw/master/WebPanel.zip
unzip WebPanel.zip
rm -f WebPanel.zip
chown -R www-data:www-data /home/web/public_html
chmod -R g+rw /home/web/public_html

# mysql
mysql -u root -p
CREATE DATABASE IF NOT EXISTS WebPanel;EXIT;
chmod 777 /home/web/public_html/application/config/database.php
apt-get install php5-mysqlnd
