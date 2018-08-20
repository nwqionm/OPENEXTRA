#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
	echo ""
	echo "กรุณาเข้าสู่ระบบผู้ใช้ root ก่อนทำการใช้งานสคริปท์"
	echo "คำสั่งเข้าสู่ระบบผู้ใช้ root คือ sudo -i"
	echo ""
	exit
fi

if [[ ! -e /dev/net/tun ]]; then
	echo ""
	echo "TUN ไม่สามารถใช้งานได้"
	exit
fi

# Set Localtime GMT +7
ln -fs /usr/share/zoneinfo/Asia/Bangkok /etc/localtime

clear
IP=$(wget -4qO- "http://whatismyip.akamai.com/")

if [[ -e /etc/debian_version ]]; then
	OS=debian
	VERSION_ID=$(cat /etc/os-release | grep "VERSION_ID")
	GROUPNAME=nogroup
	RCLOCAL='/etc/rc.local'

	if [[ "$VERSION_ID" != 'VERSION_ID="8"' ]]; then
		echo ""
		echo "เวอร์ชั่น OS ของคุณเป็นเวอร์ชั่นที่ยังไม่รองรับ"
		echo "สำหรับเวอร์ชั่นที่รองรับได้ จะมีดังนี้..."
		echo ""
		echo "Debian 8"
		echo ""
		exit
	fi
else
	echo ""
	echo "OS ที่คุณใช้ไม่สามารถรองรับได้กับสคริปท์นี้"
	echo "สำหรับ OS ที่รองรับได้ จะมีดังนี้..."
	echo ""
	echo "Debian 8"
	echo ""
	exit
fi

# Color
GRAY='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Menu
	echo ""
	echo -e "ฟังก์ชั่นสคริปท์ ${GRAY}✿.｡.:* *.:｡✿*ﾟ’ﾟ･✿.｡.:*${NC}"
	echo ""
	echo -e "|${GRAY} 1${NC}| ติดตั้ง OPENVPN ที่ควบคุมการใช้งานผ่านเทอร์มินอล"
	echo ""
	read -p "เลือกหัวข้อฟังก์ชั่นที่ต้องการใช้งาน (ใส่ตัวเลข) : " FUNCTIONSCRIPT

case $FUNCTIONSCRIPT in

	1)

newclient () {
	cp /etc/openvpn/client-common.txt ~/$1.ovpn
	echo "<ca>" >> ~/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/ca.crt >> ~/$1.ovpn
	echo "</ca>" >> ~/$1.ovpn
	echo "<cert>" >> ~/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/issued/$1.crt >> ~/$1.ovpn
	echo "</cert>" >> ~/$1.ovpn
	echo "<key>" >> ~/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/private/$1.key >> ~/$1.ovpn
	echo "</key>" >> ~/$1.ovpn
	echo "<tls-auth>" >> ~/$1.ovpn
	cat /etc/openvpn/ta.key >> ~/$1.ovpn
	echo "</tls-auth>" >> ~/$1.ovpn
}

	clear
	echo ""
	read -p "IP Server : " -e -i $IP IP
	echo ""
	read -p "Port Server : " -e -i 1194 PORT
	echo ""
	read -p "Port Proxy : " -e -i 8080 PROXY
	echo ""
	echo -e " |${GRAY}1${NC}| UDP"
	echo -e " |${GRAY}2${NC}| TCP"
	echo ""
	read -p "Protocol : " -e -i 2 PROTOCOL
	case $PROTOCOL in
		1) 
		PROTOCOL=udp
		;;
		2) 
		PROTOCOL=tcp
		;;
	esac
	echo ""
	echo -e " |${GRAY}1${NC}| DNS Current System"
	echo -e " |${GRAY}2${NC}| DNS Google"
	echo ""
	read -p "DNS : " -e -i 1 DNS
	echo ""
	read -p "Server Name : " -e CLIENT
	echo ""
	read -n1 -r -p "กด Enter 1 ครั้งเพื่อเริ่มทำการติดตั้ง หรือกด CTRL+C เพื่อยกเลิก"

	apt-get update
	apt-get install openvpn iptables openssl ca-certificates -y

	if [[ -d /etc/openvpn/easy-rsa/ ]]; then
		rm -rf /etc/openvpn/easy-rsa/
	fi

	wget -O ~/EasyRSA-3.0.4.tgz "https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz"
	tar xzf ~/EasyRSA-3.0.4.tgz -C ~/
	mv ~/EasyRSA-3.0.4/ /etc/openvpn/
	mv /etc/openvpn/EasyRSA-3.0.4/ /etc/openvpn/easy-rsa/
	chown -R root:root /etc/openvpn/easy-rsa/
	rm -rf ~/EasyRSA-3.0.4.tgz
	cd /etc/openvpn/easy-rsa/
	./easyrsa init-pki
	./easyrsa --batch build-ca nopass
	./easyrsa gen-dh
	./easyrsa build-server-full server nopass
	./easyrsa build-client-full $CLIENT nopass
	EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
	cp pki/ca.crt pki/private/ca.key pki/dh.pem pki/issued/server.crt pki/private/server.key pki/crl.pem /etc/openvpn
	chown nobody:$GROUPNAME /etc/openvpn/crl.pem
	openvpn --genkey --secret /etc/openvpn/ta.key

	echo "port $PORT
proto $PROTOCOL
dev tun
sndbuf 0
rcvbuf 0
ca ca.crt
cert server.crt
key server.key
dh dh.pem
auth SHA512
tls-auth ta.key 0
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt" > /etc/openvpn/server.conf
	echo 'push "redirect-gateway def1 bypass-dhcp"' >> /etc/openvpn/server.conf
	case $DNS in
		1)
		if grep -q "127.0.0.53" "/etc/resolv.conf"; then
			RESOLVCONF='/run/systemd/resolve/resolv.conf'
		else
			RESOLVCONF='/etc/resolv.conf'
		fi
		# Obtain the resolvers from resolv.conf and use them for OpenVPN
		grep -v '#' $RESOLVCONF | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
			echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server.conf
		done
		;;
		2)
		echo 'push "dhcp-option DNS 8.8.8.8"' >> /etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 8.8.4.4"' >> /etc/openvpn/server.conf
		;;
	esac
	echo "keepalive 10 120
cipher AES-256-CBC
comp-lzo
user nobody
group $GROUPNAME
persist-key
persist-tun
status openvpn-status.log
verb 3
crl-verify crl.pem" >> /etc/openvpn/server.conf
echo "plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so /etc/pam.d/login" >> /etc/openvpn/server.conf
echo "client-cert-not-required" >> /etc/openvpn/server.conf
echo "username-as-common-name" >> /etc/openvpn/server.conf

	sed -i '/\<net.ipv4.ip_forward\>/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
	if ! grep -q "\<net.ipv4.ip_forward\>" /etc/sysctl.conf; then
		echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
	fi

	echo 1 > /proc/sys/net/ipv4/ip_forward
	if pgrep firewalld; then
		firewall-cmd --zone=public --add-port=$PORT/$PROTOCOL
		firewall-cmd --zone=trusted --add-source=10.8.0.0/24
		firewall-cmd --permanent --zone=public --add-port=$PORT/$PROTOCOL
		firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
		firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $IP
		firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $IP
	else
		if [[ "$OS" = 'debian' && ! -e $RCLOCAL ]]; then
			echo '#!/bin/sh -e
exit 0' > $RCLOCAL
		fi
		chmod +x $RCLOCAL

		iptables -t nat -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $IP
		sed -i "1 a\iptables -t nat -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $IP" $RCLOCAL
		if iptables -L -n | grep -qE '^(REJECT|DROP)'; then
			iptables -I INPUT -p $PROTOCOL --dport $PORT -j ACCEPT
			iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
			iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
			sed -i "1 a\iptables -I INPUT -p $PROTOCOL --dport $PORT -j ACCEPT" $RCLOCAL
			sed -i "1 a\iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT" $RCLOCAL
			sed -i "1 a\iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT" $RCLOCAL
		fi
	fi

	if hash sestatus 2>/dev/null; then
		if sestatus | grep "Current mode" | grep -qs "enforcing"; then
			if [[ "$PORT" != '1194' || "$PROTOCOL" = 'tcp' ]]; then
				semanage port -a -t openvpn_port_t -p $PROTOCOL $PORT
			fi
		fi
	fi

	EXTERNALIP=$(wget -4qO- "http://whatismyip.akamai.com/")
	if [[ "$IP" != "$EXTERNALIP" ]]; then
		echo ""
		echo "ตรวจพบเบื้องหลังเซิฟเวอร์ของคุณเป็น Network Addrsss Translation (NAT)"
		echo "NAT คืออะไร ? : http://www.greatinfonet.co.th/15396685/nat"
		echo ""
		echo "หากเซิฟเวอร์ของคุณเป็น (NAT) คุณจำเป็นต้องระบุ IP ภายนอกของคุณ"
		echo "หากไม่ใช่ กรุณาเว้นว่างไว้"
		echo "หรือหากไม่แน่ใจ กรุณาเปิดดูลิ้งค์ด้านบนเพื่อศึกษาข้อมูลเกี่ยวกับ (NAT)"
		echo ""
		read -p "External IP: " -e USEREXTERNALIP
		if [[ "$USEREXTERNALIP" != "" ]]; then
			IP=$USEREXTERNALIP
		fi
	fi

	echo "client
dev tun
proto $PROTOCOL
sndbuf 0
rcvbuf 0
remote $IP $PORT
http-proxy $IP $PROXY
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA512
cipher AES-256-CBC
comp-lzo
setenv opt block-outside-dns
key-direction 1
verb 3" > /etc/openvpn/client-common.txt
echo "auth-user-pass" >> /etc/openvpn/client-common.txt

	cd
	apt-get -y install nginx
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
	echo "<pre>Nginx</pre>" > /home/vps/public_html/index.html
	echo "<?phpinfo(); ?>" > /home/vps/public_html/info.php
	args='$args'
	uri='$uri'
	document_root='$document_root'
	fastcgi_script_name='$fastcgi_script_name'
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

# Install Proxy
if [[ -e /etc/squid3/squid.conf ]]; then
	apt-get -y remove --purge squid3
fi

		apt-get -y install squid3
		cat > /etc/squid3/squid.conf <<END
http_port $PROXY
acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 ::1
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
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
http_access allow localnet
http_access allow localhost
http_access deny all
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320
END
IP2="s/xxxxxxxxx/$IP/g";
sed -i $IP2 /etc/squid3/squid.conf;

# Restart all system installed
/etc/init.d/squid3 restart
/etc/init.d/openvpn restart
/etc/init.d/nginx restart

	wget -O /usr/local/bin/menu "https://raw.githubusercontent.com/nwqionm/OPENEXTRA/master/Menu"
	chmod +x /usr/local/bin/menu
	apt-get -y install vnstat
	cd /etc/openvpn/easy-rsa/
	./easyrsa build-client-full $CLIENT nopass
	newclient "$CLIENT"
	cp /root/$CLIENT.ovpn /home/vps/public_html/
	rm -f /root/$CLIENT.ovpn

	clear
	echo ""
	echo "OpenVPN, Squid Proxy, Nginx .....Install finish."
	echo "IP Server : $IP"
	echo "Port Server : $PORT"
	if [[ "$PROTOCOL" = 'udp' ]]; then
		echo "Protocal : UDP"
	elif [[ "$PROTOCOL" = 'tcp' ]]; then
		echo "Protocal : TCP"
	fi
	echo "Port Nginx : 85"
	echo "IP Proxy : $IP"
	echo "Port Proxy : $PROXY"
	echo ""
	echo "Download Config : http://$IP:85/$CLIENT.ovpn"
	echo ""
	echo "====================================================="
	echo -e "ติดตั้งสำเร็จ... กรุณาพิมพ์คำสั่ง${GRAY} menu ${NC} เพื่อไปยังขั้นตอนถัดไป"
	echo "====================================================="
	echo ""
	exit

	;;

	esac
