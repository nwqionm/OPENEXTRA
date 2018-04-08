#!/bin/bash

apt-get install wget
apt-get install unzip

wget https://github.com/theonemule/no-ip/archive/master.zip
unzip master.zip

mkdir /etc/no-ip
touch /etc/no-ip/no-ip.conf

echo "'
echo ""
read -p "ระบุ Username ของคุณใน no-ip.com : " -e username
read -p "ระบุ Password ของคุณใน no-ip.com : " -e password
read -p "ระบุ Hostname ของคุณใน no-ip.com : " -e hostname

cat > /etc/no-ip/no-ip.conf <<END
user=$username 
password=$password 
hostname=$hostname
logfile=/var/log/no-ip.log
interval=1
detectip=true
END

cp /root/no-ip-master/no-ip.sh /usr/sbin/no-ip.sh
chmod +x /usr/sbin/no-ip.sh
cp /root/no-ip-master/no-ip-service /etc/init.d/no-ip-service
chmod +x /etc/init.d/no-ip-service
service no-ip-service start

