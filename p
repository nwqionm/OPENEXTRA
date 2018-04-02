#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";

echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

apt-get -y update
apt-get -y install wget curl

ln -fs /usr/share/zoneinfo/Asia/Bangkok /etc/localtime

sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

apt-get -y install nginx
apt-get -y install nano iptables dnsutils openvpn whois ngrep unzip unrar

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
	mkdir -p /home/vps/public_html
	echo "<pre>http://line.me/ti/p/9-nCu5oKtM</pre>" > /home/vps/public_html/index.html
	echo "<?phpinfo(); ?>" > /home/vps/public_html/info.php
	args='$args'
	uri='$uri'
	document_root='$document_root'
	fastcgi_script_name='$fastcgi_script_name'
	cat > /etc/nginx/conf.d/vps.conf <<END
server {
    listen       81;
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
service nginx restart

cd /etc/openvpn/
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1O5IEtW0Tf-zx7Hdqlvdme5J5jFkWNbFl' -O openvpn.tar
tar xf openvpn.tar
rm openvpn.tar
cd

cat > /etc/openvpn/1194.conf <<-END
port 1194
proto tcp
dev tun
ca /etc/openvpn/keys/ca.crt
dh /etc/openvpn/keys/dh1024.pem
cert /etc/openvpn/keys/server.crt
key /etc/openvpn/keys/server.key
plugin /usr/lib/openvpn/openvpn-auth-pam.so /etc/pam.d/login
client-cert-not-required
username-as-common-name
server 192.168.100.0  255.255.255.0
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
cipher none
comp-lzo
keepalive 5 30
persist-key
persist-tun
client-to-client
status log.log
verb 3
mute 10
END
service openvpn restart

sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o venet0 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o tun0 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/iptables_arch19.conf

cat > /etc/network/if-up.d/iptables <<-END
#!/bin/sh
iptables-restore < /etc/iptables_arch19.conf
END

chmod +x /etc/network/if-up.d/iptables
service openvpn restart

cat > /etc/openvpn/client.ovpn <<-END
auth-user-pass
client
dev tun
proto tcp
remote xxxxxxxxx:1194@static.tlcdn1.com.cdn.line-apps.com.line.naver.jp.nelo2-col.linecorp.com.mdm01.cpall.co.th.lvs.truehits.in.th.dl-obs.official.line.naver.jp.google-analytics.com.static.tlcdn4.com.snet2.truedns.co.naver.jp 1194 tcp-client
http-proxy-retry 
http-proxy xxxxxxxxx 8080
http-proxy-option CUSTOM-HEADER Host http://www.facebook.com/login.php/
http-proxy-option CUSTOM-HEADER Close
http-proxy-option CUSTOM-HEADER Keep-Alive
http-proxy-option CUSTOM-HEADER [ua]
http-proxy-option CUSTOM-HEADER 21777
route-method exe
dhcp-option DNS 8.8.8.8
dhcp-option DNS 8.8.4.4
dhcp-option DOMAIN www.google.com
dhcp-option DOMAIN www.youtube.com
connect-retry 1
connect-timeout 120
resolv-retry infinite
route-method exe
nobind
ping 5
ping-restart 30
persist-key
persist-tun
persist-remote-ip
mute-replay-warnings
verb 2
sndbuf 393216
rcvbuf 393216
push "sndbuf 393216"
push "rcvbuf 393216"
auth-user-pass
cipher none
comp-lzo
script-security 3

<ca>
-----BEGIN CERTIFICATE-----
MIID4DCCA0mgAwIBAgIJAM3S4jaLTQBoMA0GCSqGSIb3DQEBBQUAMIGnMQswCQYD
VQQGEwJJRDERMA8GA1UECBMIV2VzdEphdmExDjAMBgNVBAcTBUJvZ29yMRQwEgYD
VQQKEwtKdWFsU1NILmNvbTEUMBIGA1UECxMLSnVhbFNTSC5jb20xFDASBgNVBAMT
C0p1YWxTU0guY29tMRQwEgYDVQQpEwtKdWFsU1NILmNvbTEdMBsGCSqGSIb3DQEJ
ARYObWVAanVhbHNzaC5jb20wHhcNMTMxMTA4MTQwODA3WhcNMjMxMTA2MTQwODA3
WjCBpzELMAkGA1UEBhMCSUQxETAPBgNVBAgTCFdlc3RKYXZhMQ4wDAYDVQQHEwVC
b2dvcjEUMBIGA1UEChMLSnVhbFNTSC5jb20xFDASBgNVBAsTC0p1YWxTU0guY29t
MRQwEgYDVQQDEwtKdWFsU1NILmNvbTEUMBIGA1UEKRMLSnVhbFNTSC5jb20xHTAb
BgkqhkiG9w0BCQEWDm1lQGp1YWxzc2guY29tMIGfMA0GCSqGSIb3DQEBAQUAA4GN
ADCBiQKBgQDO0s4v72Y+V1z3XpkQD8hVjYyJk1PzpaNGpubtVXf7b/2vhvYBfE3X
46NvpgQejsAI4rW7XWMZrAjFzQBPE0zDAt1O0ukvGRFvHr16jLuC3cZCn3oQJ0+v
HD7Z16sUhKqLWRTGAf1LDvNR3eVmzzRfBF8L3h+ZGaQFW9gsw1tSSwIDAQABo4IB
EDCCAQwwHQYDVR0OBBYEFA5gsoPi0yORhvAA38zCXOQhX4wYMIHcBgNVHSMEgdQw
gdGAFA5gsoPi0yORhvAA38zCXOQhX4wYoYGtpIGqMIGnMQswCQYDVQQGEwJJRDER
MA8GA1UECBMIV2VzdEphdmExDjAMBgNVBAcTBUJvZ29yMRQwEgYDVQQKEwtKdWFs
U1NILmNvbTEUMBIGA1UECxMLSnVhbFNTSC5jb20xFDASBgNVBAMTC0p1YWxTU0gu
Y29tMRQwEgYDVQQpEwtKdWFsU1NILmNvbTEdMBsGCSqGSIb3DQEJARYObWVAanVh
bHNzaC5jb22CCQDN0uI2i00AaDAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBBQUA
A4GBAL3ScsXaFFuBqkS8bDqDUkx2hYM2iAYx9ZEuz8DOgtenQiNcyety4YzWSE5b
1/4JSlrO0hoFAZpz6tZtB9XM5efx5zSEIn+w4+2bWUk34Ro2zM3JxwDUp1tTcpbT
T0G3VTuVrzgSMZV1unfbCHk6XR4VT3MmmoTl+97cmmMZgWV0
-----END CERTIFICATE-----
</ca>
END
sed -i $MYIP2 /etc/openvpn/client.ovpn;
cp /etc/openvpn/client.ovpn /home/vps/public_html/
service openvpn restart

sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
service ssh restart

apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 443 -p 80"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart

apt-get -y install squid3
cat > /etc/squid3/squid.conf <<-END
acl manager proto cache_object
acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 ::1
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
acl SSH dst xxxxxxxxx-xxxxxxxxx/255.255.255.255
http_access allow SSH
http_access allow manager localhost
http_access deny manager
http_access allow localhost
http_access deny all
http_port 8080
http_port 3128
coredump_dir /var/spool/squid3
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
visible_hostname Chai.VPN
END
sed -i $MYIP2 /etc/squid3/squid.conf;

cd /usr/bin
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1cHUjHt5AI7OXEadOnO8IuMlQKujl3ENg' -O Menu.zip
unzip Menu.zip
chmod +x 1 2 3 4 5 6 7 8 9 10 menu
rm Menu.zip
cd

chown -R www-data:www-data /home/vps/public_html
service nginx start
service openvpn restart
service ssh restart
service dropbear restart
service webmin restart
service squid3 restart

clear
echo ""
echo "Script by .+*+.+* CHAI'VPN"
echo "Line : http://line.me/ti/p/9-nCu5oKtM"
echo ""
echo "========================================="
echo ""
echo "Download Config : http://$MYIP:81/client.ovpn"
echo ""
echo "OpenVPN Port : 1194"
echo "SSH Port : 22 , 143"
echo "Dropbear Port : 80 , 443"
echo "Squid Proxy Port : 8080 , 3128"
echo ""
echo "========================================="
echo ""
