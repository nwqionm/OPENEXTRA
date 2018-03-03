#!/bin/bash

line=`cat /etc/openvpn/openvpn-status.log | wc -l`

a=$((3+((line-8)/2)))

b=$(((line-8)/2))


CLIENT=$(cat /etc/openvpn/openvpn-status.log | head -n $a | tail -n $b | cut -d "," -f 1)

RX=$(cat /etc/openvpn/openvpn-status.log | head -n $a | tail -n $b | cut -d "," -f 3)

TX=$(cat /etc/openvpn/openvpn-status.log | head -n $a | tail -n $b | cut -d "," -f 4)

CONRX=$(echo "scale=2;$RX / 1000000" | bc)
CONTX=$(echo "scale=2;$TX / 1000000" | bc)

printf "%-1s %-5s %-10\n" "$CLIENT" "$CONRX" "$CONTX"
