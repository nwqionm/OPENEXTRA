#!/bin/bash

ON=0
OFF=0
while read ONOFF
do
	ACCOUNT="$(echo $ONOFF | cut -d: -f1)"
	ID="$(echo $ONOFF | grep -v nobody | cut -d: -f3)"
	ONLINE="$(cat /etc/openvpn/openvpn-status.log | grep -Eom 1 $ACCOUNT | grep -Eom 1 $ACCOUNT)"
	if [[ $ID -ge 1000 ]]; then
		if [[ -z $ONLINE ]]; then
			OFF=$((OFF+1))
		else
			ON=$((ON+1))
		fi
done < /etc/passwd
TOTAL="$(awk -F: '$3 >= '1000' && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
echo ""
echo ""
echo -e "กำลังเชื่อมต่อ ${GREEN}$ON${NC}  |  ไม่ได้เชื่อมต่อ ${RED}$OFF${NC}  |  บัญชีทั้งหมด $TOTAL"
echo ""
exit
