read -p "Select a Choice : " CHANGESYSTEMSERVER

case $CHANGESYSTEMSERVER in

	1)
	
sed -i '28d' /etc/openvpn/server.conf
sed -i '29d' /etc/openvpn/server.conf
sed -i '30d' /etc/openvpn/server.conf
echo "client-to-client" >> /etc/openvpn/server.conf

	;;

	2)
	
sed -i '28d' /etc/openvpn/server.conf
sed -i '29d' /etc/openvpn/server.conf
sed -i '30d' /etc/openvpn/server.conf
echo "plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so /etc/pam.d/login
client-cert-not-required
username-as-common-name" >> /etc/openvpn/server.conf

	;;

	3)
	
sed -i '28d' /etc/openvpn/server.conf
sed -i '29d' /etc/openvpn/server.conf
sed -i '30d' /etc/openvpn/server.conf
echo "duplicate-cn" >> /etc/openvpn/server.conf

	;;
	
esac
