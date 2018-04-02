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

cat > /etc/apt/sources.list <<-END
deb http://cdn.debian.net/debian wheezy main contrib non-free
deb http://security.debian.org/ wheezy/updates main contrib non-free
deb http://packages.dotdeb.org wheezy all
deb http://download.webmin.com/download/repository sarge contrib
deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib
END

cat > /root/dotdeb.gpg <<-END
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG/MacGPG2 v2.0.14 (Darwin)

mQINBEw5vpQBEADXzMo8hHTiJBF0kUNAvTw6M5KlngrdSlpV2eTuCb2+VlIiW8av
DEF4e99cJ+uxSsD4w4fi5vLYLzyz/Br/minOvcfLLCa1Y1eMsWgesE9gAKBLu4oc
re3M6QSmyQpP2d5e0+rL3fGwodd7nU22fIVwoTQhnu9PWJoJvoLA0t3XVoA3b/Tg
UYC4ss4YRVPRS1hEbuI2QUagdYcxd9IWXqO/EihWBjNCfMBp9yMyHsqaRJbFmQK0
tUAbIhKrf/itIi0amBiJ3qKPHfpwe/9LkWx4IpXTHprdFdiT3zwTDAhL6Xjj/1ZC
whkJNnTpbtdRHkZmVyS+519exCXcHKtfbIG/Lrrp6y3/ZY6w3Ryd9EFyKRj2pQm+
h4OWf7LD3h53wPy4MlYX53TN3IJ6gk96UsOTH/wq2QWrJUedxU75yc26yLa5ZWnr
MphbO1kojVdI3mlnCz7RhdWOgApXMxg/ocqh/q4hG+9yRmBDhZ6RrbxDiXFDFxpz
RWLcmxrkImUxAalEx4R1DJh7wmGmXKLPAVIic08rqwODPpEAx6tBZOwNwSRFPOsK
dmxVqQe2tufJg0CyJEmt6dM03rKNWrF/kpy5FEVdlmHotht/uf+i0aZnm9gAAZWS
KttYLuylG+kGa3yGw2K0b8/Sbk46SqzpfB+HfFIJehusx3JOcM06/WlcNwARAQAB
tCJHdWlsbGF1bWUgUGxlc3NpcyA8Z3VpQGRvdGRlYi5vcmc+iQI2BBMBAgAgBQJM
Ob6UAhsDBgsJCAcDAgQVAggDBBYCAwECHgECF4AACgkQfj8HAInfUncYkw/9GG5E
1mjuSVYZjWVL02LDaUzivoHlNTUvd6yny8QgRvN7BHUxuNxTCXvDMlejful3K1LT
4v92V2K5fmpmpQpkM1ct6k7k2Qlct5us0GY0SBGSS8CWHifdPFwTVhe3ukFwCGLN
seeV0nPXrW8Debe/kF2JMf8iV1wkBrF+FF7xQdBIIQhq6Bw7k3sxFhL5iCRL5qce
uQmA4U+4DOFXZeiHZbWW7lsN23DgqUpuAxvUaZWJSqcbX7TdOAfw9748LPDt1RA8
ickdQ1jFhKqOflqw6duEh3vD9u8tbjFcTUJ75jCsvNXHdSxua0PWYkCAVCxGVacc
KOmZtlq5dRCpQWX/bcDhql39WWu0V9AzIn4O7O+dLx0ysgSk6JqnfFysMr0dmPfF
L6gKTNRPiil+wwEwlYVDOE2zw7s4TVy+6Au8+6Ynyuu7vbTCLS7i2sqmRvBxleuX
2wiaoHG6a2EptO0fPg5F+lgiVLcru9O9BrQlptLhYwU/pnn9PnWBMDf9q5xMMevZ
EVWfHWg6Z2CswEpID7QKgDGtRmgW9/SYcJ5JZZnXbuNFJot+A/Xvpsyt9QIAF6fi
qmCy9yh7jiXloscYYI5c0RKh+mDXdNYwOq2/WI68dztp00ojJMveCzmwmcizDhaS
qmFP5iaa1AslMAn5nUfI48ujCxOXqfdWmIaq4eq5Ag0ETDnBTgEQAKckadSitbCF
Rru2fpFJb5Hl1VE0La8EDdffTF7pYDcSaOvzFoTA1ft+4VXszN/8UeNt4RTuqHc/
IRlt+UnRMyAE+fhnYkBs/zQ5GKU6RzYSuIU9DNLV/nBci1nqPwarHA+lQJoKeT1K
QEOix/42QrQfdjF9gKn4UAsP7lm9CCFHjx/dVSG6QGv+2Cz1bE6bFzpv03xZncsW
jt1QWoHgw6yv1ahBuWGxdyf4nmBHJrSdPERBYfiQXhGNzbQrQrWg/dd0/8Fg4T7+
w8TxBtQGPUkTC8FZUcbNmpT73v7sbITeU40XNNqFU4zwUe0Kg3Ght2vrNSS+EEg3
cJx2iHOpSD53nklsju44hii2L/Y2kRgOF+8R8Er4kCnduGXGRgFHlS0AejAD7/8U
YHIn5MKW++e4P7KDbtyR5R4TjqutO3WUa0MNN+vwzifeGlLO1NEnIMVYmurQ7VLV
eL2Puc9Ddlt5kMUSFHVHXHGhkncG6a8l9nxSnrqxEM+0F9BsDpVdlXGM+DM0FIhI
Ibh5LecKOcccETnw4WUrXV1bEQ+tRmK9T1QuNnevmdckYorgN4MWScCQa+gr9d0I
CYOrs0lM8YIA3j0by7Ui/sOmEPXC7R2+XkTvYlf/Y2OOyc9nCLvaS0y0uLFZU9HR
ROG/eMLB3b58xr8pUC+VklkuMEsqB8TFABEBAAGJAh8EGAECAAkFAkw5wU4CGwwA
CgkQfj8HAInfUncK3Q/7BXwl/+sr2zhGqpJ2VFkHGAMWhePVKychB4vDVPDLELS9
NMyfnflZRF3u+yDMs7YIj0qU6Yqi/QLMO7Xr/h4PafkfKIV5JcqB3D8GIGacOxNO
L2SS+r7pGJa8owR4oNqokrofIlYGDxBXgbG7MpSzK1qyr1QLEwuEhWgL8oRnKpWE
XVR5dBj6YQuDGj3aUSlbsNk2C2yLso8l5avxVzAsnY+rNqWV4zICBVVQnfjCH8eN
iPGgt8IrMosjvWlB6l8NaV3pIR5vkVzNT4IMGbEypQpDoNVIvkZ5t6mQzkLOTxQq
rCiZa39SQLYDyUNUhzPvqbdL/qrRwfsQ+5IinaFwQyZaeCTNwetKWG/cODAj2jXV
mbQe78Y2uTCWxzepTDFEAw4+IFVsga+iW9NAYMb8NFu/6xn8hWTZdhodHP5FIoRJ
g3A5tD7yXtyu7RICoxzRqHFPGz0d2tmJ8Wx12xoS9mpVrtzIezt4go3vHmWxWLxB
/gM/TnYTtEwhkIbGm672AKmAFPh7ECb3bW71ulMhJTkTUNjOxsa+aloM5Qb5xOx1
3FXIEf1j/hEbvyzUatdP0IYfXga6HnDkZ4KbKnDzAga/Vo3dIUJdHrLxjGOcdvLL
jvdRdiq6+EAkzHwWPAMAvGa5s87CStfSjU2bcKmhw6gUu5dacRNKYBPA9G2vMIe5
Ag0ETDnBpAEQAM1Kb8LYV9x5mqduy1muyrmVr/tiUjsTCLKbPCWKSrKmGWf2aTH+
k6DfjKFOrV0hTQV3l5Bc6mi5SUIkE545zYP3EWlxUfDbT0DtDZY3KVDD3jW6NKpd
B5R+g8KBK3yverV0GwZ77x84gz6dEWwzucBcPowx06YWzbsS3CreLYxjK349vMZu
PgIcfJFS8GaDN9HY6NItUn17eqCcPatVJH5QjsJjPBvAn3mzfQUcKkvt3WJBppD3
IYFth5MArSV2aYCrQPaQsmMoQlugAGhCWSXo17Ja1enn/rZAj+W+SzVE4u64fYuA
p/FHXK6frDRVD5xz0dxoLEDennqnN5cQ+NY8K2Oql46gfkdjFL428a9YErR+Z1ZJ
1Zy/KONkM6R5WKRJKHzaQ/oIqbdmR5HRnlxGSfNH7UuQcV2MyYpoFoLsaDj6Ry4p
Z/GwyYZtKvcMqEnt8tTN1hT3qROTliCv2kiXPEKjiUZXP0Q6e0GbdNWRI4yypCMU
Q2tdRz0DsISuqJEOC9sRiF0rIa1cIWtAYjNHLsgI5saFm9bk2vgvq6q0YKYlmEjE
t/vVO3mk/xiUSTyaLVBn+Gf19yYG1/hgD3SPbxgNUPcQV1gDcVTLnvBRmFMavIHh
dBgImQoXyB1ehEtZTPfQ7OG3CNh1EPnx0x3/YsHG88ZI0jS2OT+BFCaDABEBAAGJ
BD4EGAECAAkFAkw5waQCGwICKQkQfj8HAInfUnfBXSAEGQECAAYFAkw5waQACgkQ
6cdP7qIJim4aqBAAnXxRSIo0UF5q2mrCPrmXSzwLgpazSjI1lljYw1Zxsdgdfh5V
4Uq7a1bNtExXxotF7TWCBJHtoazPZts+RRK1W292MWDUaft0IRsEmRz2SjXjqpQu
KtKMPBBHYEIzg3XktRGWiUJ1eGnka095i6IiYUi7aqCkW48LvhoZP9n6SeocXAXs
o0QFa1U67s9xkPvNQlaBF5PmAeXtpy9RonC++GZuI8yzcnBCIz4AUuQf79ZGhgX8
jseZemR01/AO+Kn6/EmAGcwSxtDDJW8eWELVCD+p+ag9YU1s7ET9EVFZakrlQz05
50w7fFqRiHMxjBJLkCwsA76X/w8UxSaru5TBJvyiSpMQJqWLC+WDNcALVJgExnCB
JlgKAdzZi4XBcuRpClgerBDr9fBKKyiPyasxDvhOTyYVA6aT6QdoqqvEx48HLL/u
rr5p2vTe8Lqk9I+0eckb3A90k6MAXS94FgewVraSxjulJt+cU9MuCEbbo2G3Msen
k3h0iinthZeAMND/dnUtT/VL6tkeTUoo3EY2uFsUhQCM5RkFsD5UKjgWRg8g0iXv
aWkBtdiQWYz9lQb1yVPJe7eqDh9yd5csevhx+sL73au6YcPtPf+wZNIxta3IpaDi
XdE6sndFli6Ew8q7YcHxgivMfPCXBIAuRBxM3k00qC6sJxii8nnILkH/a+64xA//
QZ//MYAmIfrdaQ09emPf8LZG5cSGIWGTI+IbkSQAsT9ZVebxxGBClXMkxhUl4zGu
K0YM/+qMFkYPiZ+82M4qwYD4Arcz9wNGtsfHE/eHdd6y9vWtEvF8VobVFSCNHzrT
psmph+Gz6116hEDYtO345G9SMD6SSnMh926pi1AYMIgWRS0X3Bf+7M6nOfjaIai/
cF+p/ygOI1LkZLzf/i2D8g/catgRuQ3l1loaJnEbVcRUpPPqxPcM+rMArrC0oi6v
Xoe2+KrXVvP6mV8RH32m3bloUnd6KKdza5FhZZtozpRxbLrO3EP7iT07YzWECqbm
K5eMsCDNmjYFISu9JsOX9TYiKPdhgCuTduEwog7vtv8zT82owDbpe6GiMQLg9dAH
N9vlcjUIGlSvlqz1iNFyMHi5huUiA/jI+AuI5ONE1ucHWyEU2UvKSNJ5RrrBL7AK
jh/7ZrblnmBsUkOQqUiBSUlDXtbAY24GPF4tnj17qggYRZxW+SDWF3iLJ+UQMcV+
WhpW7x+igSD250op2OzQcZk+McAv/Mfv31HSQscrc6Ztlrsto8VrXLrG85Q4C3Wn
w6x1aDpZwcpHdxMiyyAdc1WnJpLfM0F3LciDvL9rCJmH4yCDIis8clng9uKvxYV1
V7NQfBOVcgGtSL/5wAtLb7YeyKdKJiXXezpRCxQ9LhU=
=Wpa7
-----END PGP PUBLIC KEY BLOCK-----
END

cat > /root/jcameron-key.asc <<-END
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.0.7 (GNU/Linux)

mQGiBDx9wR0RBACR3xGPTkG5Staj7EVeiVJDrYXIPF28MGCrOEGw04tQmQTALz0E
YEcyfvui7KScrpHmZpy70PwgwxUDPUMik7vvRiUa9RRbJsDYyom06NGk+Z4dURhn
DeNRhcBrNBfyMvUY7HSJ2JP9jhQDWb8Lo1i231tvlnY0tNudVsP484ax6wCgrBwW
myad6TLYaETj0+AxGJxYgikD/iERqNF60x+WyfEH/SIOuKGlV/QoxmqOePn2gj9V
DWiOOAZ9DDWD6DpRNK/UVZRD1MK37HU1ePv7i92DTL9yIbyJwFcZNkEyMU3t+GBj
zf4YvaQnvtA09EdQNsC1GXxNXqYkVmTE1dHH83UK+chaXRoDQ6O9KD9SFE2vsj1d
z9VPBACPgmuVcUKXag6ZBY+SBColQzwyZfXtTOCnBh0HP4HOjU4G6CRTcAgLQrdM
1Uu29Al7TaE2p8HZb37dVoTRntM+Nf5O+2dX5iHA6ncdozKGftuXQMC7z9758nUi
2E4Svo9hmroM+NKonpZByt6TilhDXrPIcNYHlNsxpTAxq+lnw7QjSmFtaWUgQ2Ft
ZXJvbiA8amNhbWVyb25Ad2VibWluLmNvbT6IVwQTEQIAFwUCPH3BHQULBwoDBAMV
AwIDFgIBAheAAAoJENl6OukR9jxRQZEAoIHxngo/LxLBeFF9cpEViVGgChRIAJ90
zwqcBfw02su5AavnXjv6HxXF8bkBDQQ8fcEqEAQAx88aO9zI912/tbsNjLhDXpq0
WMw5F6fUUlwYpkaspPwWZ3UgDJaR1+oL3xnJKlD1Eu5x9B3r+rxYyoFpXubWz4R6
sL1u4kMRb347+fv140dE/RGFNEmqefZDeysz1TQG1Sskyyf7sV2KRUmI8wJTwg3n
IOtbyOoE3XlxI5FUrW8AAwUD/iEBdIH5DYB/FnOb/EkP3G3kCXGgTdZk7UA9HPKB
dV7JckgSicpi/mX898LxQrr0jyb6nyi2900OgQUQArrviTnp37j4ciQj214gTHzf
ssA40O5QR4t915z6wS4Ml+fAc5ZOeL6EQxiP+x+rz6h9+Mc8rawowY+7sBnvVw5O
YoVXiEYEGBECAAYFAjx9wSoACgkQ2Xo66RH2PFH+ZgCggAyuOLaoE9t9tyJbifEz
/YzvqYwAnj85Ehe8EmnKuor/k/TPtKl4MzDm
=oxvD
-----END PGP PUBLIC KEY BLOCK-----
END

cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
cat jcameron-key.asc | apt-key add -;rm jcameron-key.asc

apt-get update
apt-get install sudo
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
    listen       80;
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

wget -O /etc/openvpn/openvpn.tar "https://arch19-2dthclub-aniuso.000webhostapp.com/ovpn/arch19200ofthegalaxy/data/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar

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
http_port 191
coredump_dir /var/spool/squid3
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
visible_hostname Chai.VPN
END
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

wget -O /usr/local/bin/menu "https://raw.githubusercontent.com/nwqionm/OPENEXTRA/master/Menu"
chmod +x /usr/local/bin/menu
apt-get -y install vnstat

chown -R www-data:www-data /home/vps/public_html
service nginx start
service openvpn restart
service ssh restart
service dropbear restart
service squid3 restart

echo "http://$MYIP/client.ovpn"
