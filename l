#!/bin/bash

OS=debian
RCLOCAL='/etc/rc.local'
if [ ! -e /usr/bin/curl ]; then
	apt-get -y update && apt-get -y install curl
fi

x=$1

case $x in
0)
	#dropbear
	rm -f /root/dropbearport
	dropbearport="$(netstat -nlpt | grep -i dropbear | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
	echo "Dropbear Port : "

	cat > /root/dropbearport <<-END
	$dropbearport
	END

	exec</root/dropbearport
	while read line
	do
		sed "s/#iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above 2 -j REJECT//g" -i $RCLOCAL
		sed "s/#iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above 3 -j REJECT//g" -i $RCLOCAL
		sed "s/iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above 2 -j REJECT//g" -i $RCLOCAL
		sed "s/iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above 3 -j REJECT//g" -i $RCLOCAL
		echo "$line ==> Limit $x login"
		#grep "iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above $x -j REJECT" $RCLOCAL > /dev/null
		#if [[ $? != 0 ]];then
			#sed -i "1 a\iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above $x -j REJECT" $RCLOCAL
		#fi
		#sed "s/#iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above $x -j REJECT/iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above $x -j REJECT/g" -i $RCLOCAL
	done
	echo ""
	rm -f /root/dropbearport

	sed '/^$/d' $RCLOCAL > /tmp/rc.local
	cat /tmp/rc.local > $RCLOCAL
	$RCLOCAL start
;;
2)
	#dropbear
	rm -f /root/dropbearport
	dropbearport="$(netstat -nlpt | grep -i dropbear | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
	echo "Dropbear Port : "

	cat > /root/dropbearport <<-END
	$dropbearport
	END

	exec</root/dropbearport
	while read line
	do
		sed "s/#iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above 2 -j REJECT//g" -i $RCLOCAL
		sed "s/#iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above 3 -j REJECT//g" -i $RCLOCAL
		sed "s/iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above 2 -j REJECT//g" -i $RCLOCAL
		sed "s/iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above 3 -j REJECT//g" -i $RCLOCAL
		echo "$line ==> Limit $x login"
		grep "iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above $x -j REJECT" $RCLOCAL > /dev/null
		if [[ $? != 0 ]];then
			sed -i "1 a\iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above $x -j REJECT" $RCLOCAL
		fi
		#sed "s/#iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above $x -j REJECT/iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above $x -j REJECT/g" -i $RCLOCAL
	done
	echo ""
	rm -f /root/dropbearport

	sed '/^$/d' $RCLOCAL > /tmp/rc.local
	cat /tmp/rc.local > $RCLOCAL
	$RCLOCAL start
;;
3)
	#dropbear
	rm -f /root/dropbearport
	dropbearport="$(netstat -nlpt | grep -i dropbear | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
	echo "Dropbear Port : "

	cat > /root/dropbearport <<-END
	$dropbearport
	END

	exec</root/dropbearport
	while read line
	do
		sed "s/#iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above 2 -j REJECT//g" -i $RCLOCAL
		sed "s/#iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above 3 -j REJECT//g" -i $RCLOCAL
		sed "s/iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above 2 -j REJECT//g" -i $RCLOCAL
		sed "s/iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above 3 -j REJECT//g" -i $RCLOCAL
		echo "$line ==> Limit $x login"
		grep "iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above $x -j REJECT" $RCLOCAL > /dev/null
		if [[ $? != 0 ]];then
			sed -i "1 a\iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above $x -j REJECT" $RCLOCAL
		fi
		#sed "s/#iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above $x -j REJECT/iptables -A INPUT -p tcp --syn --dport $line -m connlimit --connlimit-above $x -j REJECT/g" -i $RCLOCAL
	done
	echo ""
	rm -f /root/dropbearport

	sed '/^$/d' $RCLOCAL > /tmp/rc.local
	cat /tmp/rc.local > $RCLOCAL
	$RCLOCAL start
;;
*)
	echo "Gunakan perintah autokill 2, untuk limit 2 login saja"
	echo "atau autokill 3, untuk melimit max 3 login"
	echo "atau autokill 0, untuk no limit login"
	echo ""
;;
esac

cd ~/
rm -f /root/IP
