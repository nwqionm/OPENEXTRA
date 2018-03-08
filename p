#!/bin/bash

ON=0
while read ONOFF
do
	CLIENTONLINE=$(echo -e "${GREEN}ONLINE${NC}")
	ACCOUNT="$(echo $ONOFF | cut -d: -f1)"
	ID="$(echo $ONOFF | grep -v nobody | cut -d: -f3)"
	ONLINE="$(cat /etc/openvpn/openvpn-status.log | grep -Eom 1 $ACCOUNT | grep -Eom 1 $ACCOUNT)"
done < /etc/passwd

echo "$CLIENTONLINE"
