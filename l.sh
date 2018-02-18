#!/bin/bash

if [[ $USER != 'root' ]]; then
	echo "Maaf, Anda harus menjalankan ini sebagai root"
	exit
fi
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
#MYIP=$(wget -qO- ipv4.icanhazip.com)

#vps="zvur";
vps="aneka";


	source="http://tepsus-slow-vpn.xyz"


# go to root
cd

# check registered ip
wget -q -O IP $source/debian7/IP.txt
if ! grep -w -q $MYIP IP; then
	echo "Only Listed IP In My Github Can Use This Script"
	if [[ $vps = "zvur" ]]; then
		echo "Hubungi: SYAHZ86"
	else
		echo "Hubungi: SYAHZ86"
	fi
	rm -f /root/IP
	exit
fi

u="syahz86"
p="syahz86"

# get the VPS IP
#ip=`ifconfig venet0:0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`
ip=$(ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1)
if [ "$ip" = "" ]; then
	ip=$(wget -qO- ipv4.icanhazip.com)
fi

echo
echo "######################################################"
echo "Downloading and Installing PoPToP"
echo "######################################################"
apt-get update
apt-get -y install pptpd

echo
echo "######################################################"
echo "Creating Server Config"
echo "######################################################"
cat > /etc/ppp/pptpd-options <<END
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 208.67.222.222
ms-dns 208.67.220.220
proxyarp
nodefaultroute
lock
nobsdcomp
END

# setting up pptpd.conf
echo "option /etc/ppp/pptpd-options" > /etc/pptpd.conf
echo "logwtmp" >> /etc/pptpd.conf
echo "localip $ip" >> /etc/pptpd.conf
echo "remoteip 10.1.0.1-100" >> /etc/pptpd.conf

# adding new user
echo "$u	*	$p	*" >> /etc/ppp/chap-secrets

echo
echo "######################################################"
echo "Forwarding IPv4 and Enabling it on boot"
echo "######################################################"
cat >> /etc/sysctl.conf <<END
net.ipv4.ip_forward=1
END
sysctl -p

echo
echo "######################################################"
echo "Updating IPtables Routing and Enabling it on boot"
echo "######################################################"
iptables -t nat -A POSTROUTING -j SNAT --to $ip
# saves iptables routing rules and enables them on-boot
iptables-save > /etc/iptables.conf

cat > /etc/network/if-pre-up.d/iptables <<END
#!/bin/sh
iptables-restore < /etc/iptables.conf
END

chmod +x /etc/network/if-pre-up.d/iptables
cat >> /etc/ppp/ip-up <<END
ifconfig ppp0 mtu 1400
END

echo
echo "######################################################"
echo "Restarting PoPToP"
echo "######################################################"
sleep 5
/etc/init.d/pptpd restart

echo
echo "######################################################"
echo "Server setup complete!"
echo "Connect to your VPS at $ip with these credentials:"
echo "Username:$u ##### Password: $p"
echo "######################################################"

cd ~/
rm -f /root/IP
