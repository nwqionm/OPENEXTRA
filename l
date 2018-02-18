#!/bin/bash

echo ""
echo -e "     ${RED}ระบุตัวเลข 30 จะทำให้บัญชีที่สร้างใช้งานไม่ได้ในอีก 30 วัน${NC}"
read -p "กำหนดวันหมดอายุ : " -e TimeActive
echo ""

CLIENTRANDOM=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
PASSWORDRANDOM=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)

useradd -e `date -d "$TimeActive days" +"%Y-%m-%d"` -s /bin/false -M $CLIENTRANDOM
EXP="$(chage -l $CLIENTRANDOM | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$PASSWORDRANDOM\n$PASSWORDRANDOM\n"|passwd $CLIENTRANDOM &> /dev/null

echo ""
echo "Client Name : $CLIENTRANDOM"
echo "Password : $PASSWORDRANDOM"
echo "Expire : $EXP"
echo ""
exit
