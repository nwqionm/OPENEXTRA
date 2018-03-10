#!/bin/bash

mkdir -p /home/vps/public_html
echo "<pre>Source by Mnm Ami | Donate via TrueMoney Wallet : 082-038-2600</pre>" > /home/vps/public_html/index.html
echo "<?phpinfo(); ?>" > /home/vps/public_html/info.php
	cat > /etc/nginx/conf.d/vps.conf <<END
server {
    listen       80;
    server_name  rentbyopenextra.com;
    access_log /var/log/nginx/vps-access.log;
    error_log /var/log/nginx/vps-error.log error;
    root   /home/vps/public_html;
    location / {
        index  index.html index.htm;
    }
}
END
