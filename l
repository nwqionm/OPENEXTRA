SETBEFORE=$(grep '^hostname' /etc/no-ip/no-ip.conf | cut -d "=" -f 2)
echo "$SETBEFORE" >> /etc/no-ip/SETBEFORE
echo ""
read -p "ระบุ Hostname ของคุณใน no-ip.com : " -e CHANGHOSTNAME

HOSTNAME="s/$SETBEFORE/$CHANGHOSTNAME/g";
sed -i $HOSTNAME /etc/no-ip/no-ip.conf;


SETHOSTNAME=$(grep '^hostname' /etc/no-ip/no-ip.conf | cut -d "=" -f 2)
HOSTNAME2="s/$SETHOSTNAME/$CHANGHOSTNAME/g";
sed -i $HOSTNAME2 /etc/openvpn/client-common.txt;

echo ""
echo "Hostname : $CHANGHOSTNAME"
echo ""
echo "ทำการแก้ไขเรียบร้อยแล้ว"
echo ""
