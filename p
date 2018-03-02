#!/bin/bash

read -p "    กรุณาระบุชื่อผู้ใช้ที่ต้องการเปลี่ยนอายุวันใช้งาน  : " username
egrep "^$username" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
read -p "    กรุณาระบุจำนวนวันที่ต้องการเปลี่ยนวันใช้งาน  : " active_time

today=`date +%s`
active_time_2=$(( $active_time * 86400 ))
time_expired=$(($today + $active_time_2))
date_expired=$(date -u --date="1970-01-01 $time_expired sec GMT" +%Y/%m/%d)
date_expired_display=$(date -u --date="1970-01-01 $time_expired sec GMT" '+%d %B %Y')

passwd -u $username
usermod -e  $date_expired $username
  egrep "^$username" /etc/passwd >/dev/null
  echo -e "$password\n$password" | passwd $username
  clear
  echo ""
  echo "---------------------------------------"
echo ""
  echo "    ชื่อผู้ใช้ $username เปลี่ยนวันหมดอายุเป็นวันที่ $date_expired_display อายุวันใช้งานรวม $active_time วัน"
echo ""
  echo "--------------------------------------"
  echo " "

else
echo ""
echo -e "    ขออภัย ไม่พบชื่อผู้ใช้ $username อยู่ในระบบ"
echo ""
exit 0
fi
