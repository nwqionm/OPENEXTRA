#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
	echo ""
	echo "กรุณาเข้าสู่ระบบผู้ใช้ root ก่อนทำการใช้งานสคริปท์"
	echo "คำสั่งเข้าสู่ระบบผู้ใช้ root คือ sudo -i"
	echo ""
	exit
fi

if [[ ! -e /dev/net/tun ]]; then
	echo "TUN ไม่สามารถใช้งานได้"
	exit
fi

# Set Localtime GMT +7
ln -fs /usr/share/zoneinfo/Asia/Bangkok /etc/localtime

clear

# Color
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Menu
echo ""
echo -e "${RED}  (\_(\  ${NC}"
echo -e "${RED} (=’ :’) :* ${NC} Script by Mnm Ami"
echo -e "${RED}  (,(”)(”) °.¸¸.• ${NC}"
echo ""
echo -e "FUNCTION SCRIPT ${RED}✿.｡.:* *.:｡✿*ﾟ’ﾟ･✿.｡.:*${NC}"
echo ""
echo -e "|${RED}1${NC}| OPENVPN TERMINAL CONTROL ${GREEN} ✔   ${NC}"
echo "	Ubuntu 14.04 - 16.04 - 17.04"
echo "	Debian 8 - 9"
echo -e "|${RED}2${NC}| OPENVPN PRITUNL CONTROL ${GREEN} ✔   ${NC}"
echo "	Ubuntu 14.04 - 16.04 - 17.04"
echo "	Debian 7 - 8 - 9"
echo -e "|${RED}3${NC}| SSH + DROPBEAR ${RED} ✖   ${NC}"
echo -e "|${RED}4${NC}| WEB PANEL ${RED} ✖   ${NC}"
echo -e "|${RED}5${NC}| VNSTAT (CHECK BANDWIDTH or DATA) ${RED} ✖   ${NC}"
echo -e "|${RED}6${NC}| SQUID PROXY ${GREEN} ✔   ${NC}"
echo "	Ubuntu 12.04 - 14.04 - 16.04 - 17.04"
echo "	Debian 7 - 8 - 9"
echo -e "|${RED}7${NC}| REMOVE OPENVPN TERMINAL CONTROL ${GREEN} ✔   ${NC}"
echo -e "|${RED}8${NC}| REMOVE SQUID PROXY ${GREEN} ✔   ${NC}"
echo ""
echo -e "${RED}ฟังก์ชั่นที่ 1 และ 2 เลือกอย่างใดอย่างหนึ่งเท่านั้น${NC}"
echo ""
read -p "กรุณาเลือกฟังก์ชั่นที่ต้องการติดตั้ง (ตัวเลข) : " MENU

case $MENU in

1)

if [[ -e /etc/debian_version ]]; then
	OS="debian"
	VERSION_ID=$(cat /etc/os-release | grep "VERSION_ID")
	IPTABLES='/etc/iptables/iptables.rules'
	SYSCTL='/etc/sysctl.conf'

	if [[ "$VERSION_ID" != 'VERSION_ID="7"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="8"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="9"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="14.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="16.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="17.04"' ]]; then
		echo ""
		echo "เวอร์ชั่น OS ของคุณเป็นเวอร์ชั่นเก่าที่ไม่รองรับแล้ว"
		echo "สำหรับเวอร์ชั่นที่รองรับได้ จะมีดังนี้..."
		echo ""
		echo "Ubuntu 14.04 - 16.04 - 17.04"
		echo "Debian 7 - 8 - 9"
		echo ""
		exit
	fi
else
	echo ""
	echo "OS ที่คุณใช้ไม่สามารถรองรับได้กับสคริปท์นี้"
	echo "สำหรับ OS ที่รองรับได้ จะมีดังนี้..."
	echo ""
	echo "Ubuntu 14.04 - 16.04 - 17.04"
	echo "Debian 7 - 8 - 9"
	echo ""
	exit
fi

newclient () {

	if [ -e /home/$1 ]; then
		homeDir="/home/$1"
	elif [ ${SUDO_USER} ]; then
		homeDir="/home/${SUDO_USER}"
	else
		homeDir="/root"
	fi

	cp /etc/openvpn/client-template.txt $homeDir/$1.ovpn
	echo "<ca>" >> $homeDir/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/ca.crt >> $homeDir/$1.ovpn
	echo "</ca>" >> $homeDir/$1.ovpn
	echo "<cert>" >> $homeDir/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/issued/$1.crt >> $homeDir/$1.ovpn
	echo "</cert>" >> $homeDir/$1.ovpn
	echo "<key>" >> $homeDir/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/private/$1.key >> $homeDir/$1.ovpn
	echo "</key>" >> $homeDir/$1.ovpn
	echo "key-direction 1" >> $homeDir/$1.ovpn
	echo "<tls-auth>" >> $homeDir/$1.ovpn
	cat /etc/openvpn/tls-auth.key >> $homeDir/$1.ovpn
	echo "</tls-auth>" >> $homeDir/$1.ovpn
}

IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [[ "$IP" = "" ]]; then
	IP=$(wget -qO- ipv4.icanhazip.com)
fi
NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)

if [[ -e /etc/openvpn/server.conf ]]; then
	echo ""
	echo "ระบบตรวจสอบพบว่า"
	echo "คุณได้ทำการติดตั้งเซิฟเวอร์ OpenVPN ไปก่อนหน้านี้แล้ว"
	echo ""
	exit
else
	clear
	echo ""
	read -p "IP address : " -e -i $IP IP
	read -p "Port : " -e -i 1194 PORT
	while [[ $PROTOCOL != "TCP" && $PROTOCOL != "UDP" ]]; do
		read -p "Protocol : " -e -i TCP PROTOCOL
	done
	read -p "Port proxy : " -e -i 8080 PROXY
	while [[ $CLIENT = "" ]]; do
		read -p "Client name : " -e CLIENT
	done
	echo ""
	read -n1 -r -p "กด ENTER 1 ครั้งเพื่อเริ่มทำการติดตั้ง หรือกด CTRL+C เพื่อยกเลิก..."

	if [[ "$OS" = 'debian' ]]; then
		apt-get install ca-certificates -y

		if [[ "$VERSION_ID" = 'VERSION_ID="7"' ]]; then
			echo "deb http://build.openvpn.net/debian/openvpn/stable wheezy main" > /etc/apt/sources.list.d/openvpn.list
			wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add -
			apt-get update
		fi

		if [[ "$VERSION_ID" = 'VERSION_ID="8"' ]]; then
			echo "deb http://build.openvpn.net/debian/openvpn/stable jessie main" > /etc/apt/sources.list.d/openvpn.list
			wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add -
			apt update
		fi

		if [[ "$VERSION_ID" = 'VERSION_ID="14.04"' ]]; then
			echo "deb http://build.openvpn.net/debian/openvpn/stable trusty main" > /etc/apt/sources.list.d/openvpn.list
			wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add -
			apt-get update
		fi

		apt-get install openvpn iptables openssl wget ca-certificates curl -y

		if [[ ! -e /etc/systemd/system/iptables.service ]]; then
			mkdir /etc/iptables
			iptables-save > /etc/iptables/iptables.rules
			echo "#!/bin/sh
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT" > /etc/iptables/flush-iptables.sh
			chmod +x /etc/iptables/flush-iptables.sh
			echo "[Unit]
Description=Packet Filtering Framework
DefaultDependencies=no
Before=network-pre.target
Wants=network-pre.target
[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore /etc/iptables/iptables.rules
ExecReload=/sbin/iptables-restore /etc/iptables/iptables.rules
ExecStop=/etc/iptables/flush-iptables.sh
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/iptables.service
			systemctl daemon-reload
			systemctl enable iptables.service
		fi
	fi

	if grep -qs "^nogroup:" /etc/group; then
		NOGROUP=nogroup
	else
		NOGROUP=nobody
	fi

	if [[ -d /etc/openvpn/easy-rsa/ ]]; then
		rm -rf /etc/openvpn/easy-rsa/
	fi

	wget -O ~/EasyRSA-3.0.4.tgz https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz
	tar xzf ~/EasyRSA-3.0.4.tgz -C ~/
	mv ~/EasyRSA-3.0.4/ /etc/openvpn/
	mv /etc/openvpn/EasyRSA-3.0.4/ /etc/openvpn/easy-rsa/
	chown -R root:root /etc/openvpn/easy-rsa/
	rm -rf ~/EasyRSA-3.0.4.tgz
	cd /etc/openvpn/easy-rsa/
	echo "set_var EASYRSA_KEY_SIZE 3072" > vars

	./easyrsa init-pki
	./easyrsa --batch build-ca nopass
	openssl dhparam -out dh.pem 3072
	./easyrsa build-server-full server nopass
	./easyrsa build-client-full $CLIENT nopass
	EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
	openvpn --genkey --secret /etc/openvpn/tls-auth.key
	cp pki/ca.crt pki/private/ca.key dh.pem pki/issued/server.crt pki/private/server.key /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn
	chmod 644 /etc/openvpn/crl.pem

	echo "port $PORT" > /etc/openvpn/server.conf
	if [[ "$PROTOCOL" = 'TCP' ]]; then
		echo "proto tcp" >> /etc/openvpn/server.conf
	elif [[ "$PROTOCOL" = 'UDP' ]]; then
		echo "proto udp" >> /etc/openvpn/server.conf
	fi
	echo "dev tun
user nobody
group $NOGROUP
persist-key
persist-tun
keepalive 10 120
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt" >> /etc/openvpn/server.conf

	grep -v '#' /etc/resolv.conf | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
		echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server.conf
	done

echo 'push "redirect-gateway def1 bypass-dhcp" '>> /etc/openvpn/server.conf
echo "crl-verify crl.pem
ca ca.crt
cert server.crt
key server.key
tls-auth tls-auth.key 0
dh dh.pem
auth SHA256
cipher AES-128-CBC
tls-server
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-128-GCM-SHA256
status openvpn.log
verb 3
client-to-client" >> /etc/openvpn/server.conf

	if [[ ! -e $SYSCTL ]]; then
		touch $SYSCTL
	fi

	sed -i '/\<net.ipv4.ip_forward\>/c\net.ipv4.ip_forward=1' $SYSCTL
	if ! grep -q "\<net.ipv4.ip_forward\>" $SYSCTL; then
		echo 'net.ipv4.ip_forward=1' >> $SYSCTL
	fi

	echo 1 > /proc/sys/net/ipv4/ip_forward
	iptables -t nat -A POSTROUTING -o $NIC -s 10.8.0.0/24 -j MASQUERADE
	iptables-save > $IPTABLES
	if pgrep firewalld; then

		if [[ "$PROTOCOL" = 'TCP' ]]; then
			firewall-cmd --zone=public --add-port=$PORT/tcp
			firewall-cmd --permanent --zone=public --add-port=$PORT/tcp
		elif [[ "$PROTOCOL" = 'UDP' ]]; then
			firewall-cmd --zone=public --add-port=$PORT/udp
			firewall-cmd --permanent --zone=public --add-port=$PORT/udp
		fi
		firewall-cmd --zone=trusted --add-source=10.8.0.0/24
		firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
	fi
	if iptables -L -n | grep -qE 'REJECT|DROP'; then

		if [[ "$PROTOCOL" = 'TCP' ]]; then
			iptables -I INPUT -p tcp --dport $PORT -j ACCEPT
		elif [[ "$PROTOCOL" = 'UDP' ]]; then
			iptables -I INPUT -p udp --dport $PORT -j ACCEPT
		fi
		iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
		iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
		
	iptables-save > $IPTABLES
	fi

	if hash sestatus 2>/dev/null; then
		if sestatus | grep "Current mode" | grep -qs "enforcing"; then
			if [[ "$PORT" != '1194' ]]; then
				if [[ "$PROTOCOL" = 'TCP' ]]; then
					semanage port -a -t openvpn_port_t -p tcp $PORT
				elif [[ "$PROTOCOL" = 'UDP' ]]; then
					semanage port -a -t openvpn_port_t -p udp $PORT
				fi
			fi
		fi
	fi

	if [[ "$OS" = 'debian' ]]; then
		if pgrep systemd-journal; then
			sed -i 's|LimitNPROC|#LimitNPROC|' /lib/systemd/system/openvpn\@.service
			sed -i 's|/etc/openvpn/server|/etc/openvpn|' /lib/systemd/system/openvpn\@.service
			sed -i 's|%i.conf|server.conf|' /lib/systemd/system/openvpn\@.service
			systemctl daemon-reload
			systemctl restart openvpn
			systemctl enable openvpn
		else
			/etc/init.d/openvpn restart
		fi
	fi

	EXTERNALIP=$(wget -qO- ipv4.icanhazip.com)
	if [[ "$IP" != "$EXTERNALIP" ]]; then
		echo ""
		echo "ตรวจพบเบื้องหลังเซิฟเวอร์ของคุณเป็น Network Addrsss Translation (NAT)"
		echo "NAT คืออะไร ? : http://www.greatinfonet.co.th/15396685/nat"
		echo ""
		echo "หากเซิฟเวอร์ของคุณเป็น (NAT) คุณจำเป็นต้องระบุ IP ภายนอกของคุณ"
		echo "หากไม่ใช่ กรุณาเว้นว่างไว้"
		echo "หรือหากไม่แน่ใจ กรุณาเปิดดูลิ้งค์ด้านบนเพื่อศึกษาข้อมูลเกี่ยวกับ (NAT)"
		echo ""
		read -p "External IP or domain name : " -e USEREXTERNALIP

		if [[ "$USEREXTERNALIP" != "" ]]; then
			IP=$USEREXTERNALIP
		fi
	fi

	echo "client" > /etc/openvpn/client-template.txt
	if [[ "$PROTOCOL" = 'TCP' ]]; then
		echo "proto tcp-client" >> /etc/openvpn/client-template.txt
	elif [[ "$PROTOCOL" = 'UDP' ]]; then
		echo "proto udp" >> /etc/openvpn/client-template.txt
	fi
	echo "remote $IP:$PORT@static.tlcdn1.com/cdn.line-apps.com/line.naver.jp/nelo2-col.linecorp.com/mdm01.cpall.co.th/lvs.truehits.in.th/dl-obs.official.line.naver.jp $PORT
http-proxy $IP $PROXY
dev tun
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA256
auth-nocache
cipher AES-128-CBC
tls-client
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-128-GCM-SHA256
setenv opt block-outside-dns
verb 3" >> /etc/openvpn/client-template.txt


	apt-get -y install nginx
	cd
	rm /etc/nginx/sites-enabled/default
	rm /etc/nginx/sites-available/default
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
	echo "<pre>Source by Mnm Ami | Donate via TrueMoney Wallet : 082-038-2600</pre>" > /home/vps/public_html/index.html
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

	if [[ "$OS" = 'debian' ]]; then
		if [[ "$VERSION_ID" = 'VERSION_ID="7"' || "$VERSION_ID" = 'VERSION_ID="8"' || "$VERSION_ID" = 'VERSION_ID="12.04"' || "$VERSION_ID" = 'VERSION_ID="14.04"' ]]; then
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
			service squid3 restart

		elif [[ "$VERSION_ID" = 'VERSION_ID="9"' || "$VERSION_ID" = 'VERSION_ID="16.04"' || "$VERSION_ID" = 'VERSION_ID="17.04"' ]]; then
			if [[ -e /etc/squid/squid.conf ]]; then
				apt-get -y remove --purge squid
			fi
			apt-get -y install squid
			cat > /etc/squid/squid.conf <<END
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
			sed -i $IP2 /etc/squid/squid.conf;
			service squid restart
		fi
	fi
	
	wget -O /usr/local/bin/menu "https://raw.githubusercontent.com/nwqionm/OPENEXTRA/master/menu"
	chmod +x /usr/local/bin/menu
	newclient "$CLIENT"
	cp /root/$CLIENT.ovpn /home/vps/public_html/
	rm $CLIENT.ovpn
	echo ""
	echo "Source by Mnm Ami"
	echo "Donate via TrueMoney Wallet : 082-038-2600"
	echo ""
	echo "OpenVPN, Squid Proxy, Nginx .....Install finish."
	echo "IP Server : $IP"
	echo "Port : $PORT"
	echo "Protocal : $PROTOCAL"
	echo "Proxy : $IP"
	echo "Port Proxy : $PROXY"
	echo "Download my Config : $IP:80/$CLIENT.ovpn"
	echo "====================================================="
	echo "ติดตั้งสำเร็จ... กรุณาพิมพ์คำสั่ง menu เพื่อไปยังขั้นตอนถัดไป"
	echo "====================================================="
	exit

fi
;;

2)

IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [[ "$IP" = "" ]]; then
	IP=$(wget -qO- ipv4.icanhazip.com)
fi
	echo ""
	read -p "Port Proxy (แนะนำ 8080) : " -e -i 8080 PROXY


if [[ -e /etc/debian_version ]]; then
	OS="debian"
	VERSION_ID=$(cat /etc/os-release | grep "VERSION_ID")
	IPTABLES='/etc/iptables/iptables.rules'
	SYSCTL='/etc/sysctl.conf'

	if [[ "$VERSION_ID" != 'VERSION_ID="8"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="9"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="14.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="16.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="17.04"' ]]; then
		echo ""
		echo "เวอร์ชั่น OS ของคุณเป็นเวอร์ชั่นเก่าที่ไม่รองรับแล้ว"
		echo "สำหรับเวอร์ชั่นที่รองรับได้ จะมีดังนี้..."
		echo ""
		echo "Ubuntu 14.04 - 16.04 - 17.04"
		echo "Debian 8 - 9"
		echo ""
		exit
	fi
else
	echo ""
	echo "OS ที่คุณใช้ไม่สามารถรองรับได้กับสคริปท์นี้"
	echo "สำหรับ OS ที่รองรับได้ จะมีดังนี้..."
	echo ""
	echo "Ubuntu 14.04 - 16.04 - 17.04"
	echo "Debian 8 - 9"
	echo ""
	exit
fi

if [[ "$OS" = 'debian' ]]; then

	# Debian 8
	if [[ "$VERSION_ID" = 'VERSION_ID="8"' ]]; then

		echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.6 main" > /etc/apt/sources.list.d/mongodb-org-3.6.list
		echo "deb http://repo.pritunl.com/stable/apt jessie main" > /etc/apt/sources.list.d/pritunl.list
		apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
		apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
		apt-get update
		apt-get --assume-yes install pritunl mongodb-org
		systemctl start mongod pritunl
		systemctl enable mongod pritunl

			while [[ $Squid3 != "Y" && $Squid3 != "N" ]]; do

				echo ""
				read -p "ต้องการติดตั้ง Squid Proxy หรือไม่ (Y or N) : " -e -i Y Squid3

			done

	# Debian 9
	elif [[ "$VERSION_ID" = 'VERSION_ID="9"' ]]; then

		echo "deb http://repo.pritunl.com/stable/apt stretch main" > /etc/apt/sources.list.d/pritunl.list
		apt-get -y install dirmngr
		apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
		apt-get update
		apt-get --assume-yes install pritunl mongodb-server
		systemctl start mongodb pritunl
		systemctl enable mongodb pritunl

			while [[ $Squid != "Y" && $Squid != "N" ]]; do

				echo ""
				read -p "ต้องการติดตั้ง Squid Proxy หรือไม่ (Y or N) : " -e -i Y Squid

			done

	# Ubuntu 14.04
	elif [[ "$VERSION_ID" = 'VERSION_ID="14.04"' ]]; then

		echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.6 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.6.list
		echo "deb http://repo.pritunl.com/stable/apt trusty main" > /etc/apt/sources.list.d/pritunl.list
		apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
		apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
		apt-get update
		apt-get --assume-yes install pritunl mongodb-org
		service pritunl start

			while [[ $Squid3 != "Y" && $Squid3 != "N" ]]; do

				echo ""
				read -p "ต้องการติดตั้ง Squid Proxy หรือไม่ (Y or N) : " -e -i Y Squid

			done

	# Ubuntu 16.04
	elif [[ "$VERSION_ID" = 'VERSION_ID="16.04"' ]]; then

		echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.6.list
		echo "deb http://repo.pritunl.com/stable/apt xenial main" > /etc/apt/sources.list.d/pritunl.list
		apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
		apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
		apt-get update
		apt-get --assume-yes install pritunl mongodb-org
		systemctl start pritunl mongod
		systemctl enable pritunl mongod

			while [[ $Squid != "Y" && $Squid != "N" ]]; do

				echo ""
				read -p "ต้องการติดตั้ง Squid Proxy หรือไม่ (Y or N) : " -e -i Y Squid

			done

	# Ubuntu 17.04
	elif [[ "$VERSION_ID" = 'VERSION_ID="17.04"' ]]; then

		echo "deb http://repo.pritunl.com/stable/apt zesty main" > /etc/apt/sources.list.d/pritunl.list
		apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
		apt-get update
		apt-get --assume-yes install pritunl mongodb-server
		systemctl start pritunl mongodb
		systemctl enable pritunl mongodb

			while [[ $Squid != "Y" && $Squid != "N" ]]; do

				echo ""
				read -p "ต้องการติดตั้ง Squid Proxy หรือไม่ (Y or N) : " -e -i Y Squid

			done

	fi

	if [[ "$Squid3" = "N" || "$Squid" = "N" ]]; then

		echo ""
		echo "Source by Mnm Ami"
		echo "Donate via TrueMoney Wallet : 082-038-2600"
		echo ""
		echo "Pritunl .....Install Finish."
		echo "No Proxy"
		echo ""
		echo "Pritunl : http://$IP"
		echo ""
		pritunl setup-key
		echo ""
		exit

	fi

	if [[ "$Squid3" = "Y" ]]; then

		echo ""
		read -p "Port Proxy (แนะนำ 8080) : " -e -i 8080 PROXY

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
		service squid3 restart
		echo ""
		echo "Source by Mnm Ami"
		echo "Donate via TrueMoney Wallet : 082-038-2600"
		echo ""
		echo "Pritunl .....Install Finish."
		echo "Proxy : $IP"
		echo "Port  : $PROXY"
		echo ""
		echo "Pritunl : http://$IP"
		echo ""
		pritunl setup-key
		echo ""
		exit

	elif [[ "$Squid" = "Y" ]]; then
		
		echo ""
		read -p "Port Proxy (แนะนำ 8080) : " -e -i 8080 PROXY

		apt-get -y install squid
		cat > /etc/squid/squid.conf <<END
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
		sed -i $IP2 /etc/squid/squid.conf;
		service squid restart
		echo ""
		echo "Source by Mnm Ami"
		echo "Donate via TrueMoney Wallet : 082-038-2600"
		echo ""
		echo "Pritunl .....Install Finish."
		echo "Proxy : $IP"
		echo "Port  : $PROXY"
		echo ""
		echo "Pritunl : http://$IP"
		echo ""
		pritunl setup-key
		echo ""
		exit
	fi

fi
;;

3)
;;
4)
;;
5)
;;

6)


if [[ -e /etc/squid/squid.conf || -e /etc/squid3/squid.conf ]]; then

	while [[ $EVERSQUID != "Y" && $EVERSQUID != "N" ]]; do
		echo ""
		echo "OS ของคุณเคยติดตั้ง Squid Proxy ไปก่อนหน้านี้แล้ว"
		echo "หากเซิฟเวอร์เกิดเหตุขัดข้องที่เกี่ยวกับ Squid Proxy"
		echo "สามารถที่จะติดตั้งใหม่อีกครั้งได้"
		echo ""
		read -p "ต้องการติดตั้ง Squid Proxy ใหม่ หรือไม่ ? (Y or N) : " -e -i Y EVERSQUID
	done

	if [[ "$EVERSQUID" = "N" ]]; then
		exit
	fi
fi

IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [[ "$IP" = "" ]]; then
	IP=$(wget -qO- ipv4.icanhazip.com)
fi
	echo ""
	read -p "Port Proxy (แนะนำ 8080) : " -e -i 8080 PROXY


if [[ -e /etc/debian_version ]]; then
	OS="debian"
	VERSION_ID=$(cat /etc/os-release | grep "VERSION_ID")
	IPTABLES='/etc/iptables/iptables.rules'
	SYSCTL='/etc/sysctl.conf'

	if [[ "$VERSION_ID" != 'VERSION_ID="7"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="8"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="9"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="14.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="16.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="17.04"' ]]; then
		echo ""
		echo "เวอร์ชั่น OS ของคุณเป็นเวอร์ชั่นเก่าที่ไม่รองรับแล้ว"
		echo "สำหรับเวอร์ชั่นที่รองรับได้ จะมีดังนี้..."
		echo ""
		echo "Ubuntu 12.04 - 14.04 - 16.04 - 17.04"
		echo "Debian 7 - 8 - 9"
		echo ""
		exit
	fi
else
	echo ""
	echo "OS ที่คุณใช้ไม่สามารถรองรับได้กับสคริปท์นี้"
	echo "สำหรับ OS ที่รองรับได้ จะมีดังนี้..."
	echo ""
	echo "Ubuntu 12.04 - 14.04 - 16.04 - 17.04"
	echo "Debian 7 - 8 - 9"
	echo ""
	exit
fi

	if [[ "$OS" = 'debian' ]]; then
		if [[ "$VERSION_ID" = 'VERSION_ID="7"' || "$VERSION_ID" = 'VERSION_ID="8"' || "$VERSION_ID" = 'VERSION_ID="12.04"' || "$VERSION_ID" = 'VERSION_ID="14.04"' ]]; then
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
			service squid3 restart
			echo ""
			echo "Source by Mnm Ami"
			echo "Donate via TrueMoney Wallet : 082-038-2600"
			echo ""
			echo "Squid Proxy .....Install Finish."
			echo "Proxy : $IP"
			echo "Port Proxy : $PROXY"
			echo ""
			exit

		elif [[ "$VERSION_ID" = 'VERSION_ID="9"' || "$VERSION_ID" = 'VERSION_ID="16.04"' || "$VERSION_ID" = 'VERSION_ID="17.04"' ]]; then
			if [[ -e /etc/squid/squid.conf ]]; then
				apt-get -y remove --purge squid
			fi

			apt-get -y install squid
			cat > /etc/squid/squid.conf <<END
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
			sed -i $IP2 /etc/squid/squid.conf;
			service squid restart
			echo ""
			echo "Source by Mnm Ami"
			echo "Donate via TrueMoney Wallet : 082-038-2600"
			echo ""
			echo "Squid Proxy .....Install Finish."
			echo "Proxy : $IP"
			echo "Port Proxy : $PROXY"
			echo ""
			exit
		fi
	fi
;;

7)

clear
echo ""
while [[ $REMOVE != "YES" && $REMOVE != "NO" ]]; do
	read -p "Do You Really Want To Remove OpenVPN ? (YES or NO) : " -e -i NO REMOVE
done

if [[ "$REMOVE" = 'YES' ]]; then
	PORT=$(grep '^port ' /etc/openvpn/server.conf | cut -d " " -f 2)

	if pgrep firewalld; then
		firewall-cmd --zone=public --remove-port=$PORT/udp
		firewall-cmd --zone=trusted --remove-source=10.8.0.0/24
		firewall-cmd --permanent --zone=public --remove-port=$PORT/udp
		firewall-cmd --permanent --zone=trusted --remove-source=10.8.0.0/24
	fi
	if iptables -L -n | grep -qE 'REJECT|DROP'; then
		if [[ "$PROTOCOL" = 'udp' ]]; then
			iptables -D INPUT -p udp --dport $PORT -j ACCEPT
		else
			iptables -D INPUT -p tcp --dport $PORT -j ACCEPT
		fi
		iptables -D FORWARD -s 10.8.0.0/24 -j ACCEPT
		iptables-save > $IPTABLES
	fi
	iptables -t nat -D POSTROUTING -o $NIC -s 10.8.0.0/24 -j MASQUERADE
	iptables-save > $IPTABLES
	if hash sestatus 2>/dev/null; then
		if sestatus | grep "Current mode" | grep -qs "enforcing"; then
			if [[ "$PORT" != '1194' ]]; then
				semanage port -d -t openvpn_port_t -p udp $PORT
			fi
		fi
	fi

	apt-get autoremove --purge -y openvpn
	rm -rf /etc/openvpn
	rm -rf /usr/share/doc/openvpn*
	echo ""
	echo "OpenVPN Removed."
	echo ""
	exit
else
	echo ""
	echo "Removal Aborted."
	echo ""
	exit
fi
	;;

8)

if [[ -e /etc/squid/squid.conf ]]; then
	apt-get -y remove --purge squid
	echo ""
	echo "Squid Proxy Removed."
	echo ""
	exit
elif [[ -e /etc/squid3/squid.conf ]]; then
	apt-get -y remove --purge squid3
	echo ""
	echo "Squid Proxy Removed."
	echo ""
	exit
fi
;;

esac
