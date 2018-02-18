#!/bin/bash

ether=`ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:`
if [[ $ether = "" ]]; then
	ether=eth0
elif [[ $ether = "" ]]; then
	ether=tun0
elif [[ $ether = "" ]]; then
	ether=ens18
fi

if [[ $ether = "eth0" ]]; then
echo "eth0"
exit
elif [[ $ether = "tun0" ]]; then
echo "tun0"
exit
elif [[ $ether = "ens18" ]]; then
echo "ens18"
exit
fi
