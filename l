#!/bin/bash

clear
echo ""
echo -e "|${GRAY} 1${NC}| เปิดใช้งานการปรับแต่งความเร็วอินเทอร์เน็ต"
echo -e "|${GRAY} 2${NC}| ปิดใช้งานการปรับแต่งความเร็วอินเทอร์เน็ต"
echo ""
read -p "เลือกหัวข้อเมนูที่ต้องการใช้งาน : " LIMITINTERNET


echo ""
echo "วิธีการใส่ : เช่นต้องการให้มีความเร็ว 10Mbps ให้ใส่ ${GRAY}10mbit${NC}  "
echo "         หากต้องการให้มีความเร็ว 512Kbps ให้ใส่ ${GRAY}512kbit${NC}  "
echo ""
read -p "ใส่จำนวนความเร็วการดาวน์โหลด : " -e $CHDL
read -p "ใส่จำนวนความเร็วการอัพโหลด : " -e CHUL

DNLD=$CHDL
UPLD=$CHUL

TC=/sbin/tc

IF="$(ip ro | awk '$1 == "default" { print $5 }')"
IP="$(ip -o ro get $(ip ro | awk '$1 == "default" { print $3 }') | awk '{print $5}')/32"     # Host IP

U32="$TC filter add dev $IF protocol ip parent 1: prio 1 u32"

case $LIMITINTERNET in

	1)

    $TC qdisc add dev $IF root handle 1: htb default 30
    $TC class add dev $IF parent 1: classid 1:1 htb rate $DNLD
    $TC class add dev $IF parent 1: classid 1:2 htb rate $UPLD
    $U32 match ip dst $IP flowid 1:1
    $U32 match ip src $IP flowid 1:2
    echo ""
    echo "เปิดใช้งานการปรับแต่งความเร็วอินเทอร์เน็ต"
    echo ""

	;;

	2)

    $TC qdisc del dev $IF root
    echo ""
    echo "ปิดใช้งานการปรับแต่งความเร็วอินเทอร์เน็ต"
    echo ""

	;;

esac
