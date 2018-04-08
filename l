SETHOSTNAME=$(grep '^hostname' /etc/no-ip/no-ip.conf | cut -d "=" -f 2)
echo "$SETHOSTNAME" >> /etc/no-ip/$SETHOSTNAME
echo ""
read -p "ระบุ Hostname ของคุณใน no-ip.com : " -e CHANGHOSTNAME

HOSTNAME="s/$SETHOSTNAME/$CHANGHOSTNAME/g";
sed -i $HOSTNAME /etc/openvpn/client-common.txt;
echo ""
echo "Hostname : $CHANGHOSTNAME"
echo ""
echo "ทำการแก้ไขเรียบร้อยแล้ว"
echo ""
