#!/bin/bash

GRAY='\033[1;33m'
NC='\033[0m'

clear
echo ""
echo "  (\_(\ "
echo " (=’ :’) :* Script by Apiwat Panyoi"
echo "  (,(”)(”) °.¸¸.• Edit the Script by Mnm Ami"
echo ""
echo -e "${GRAY}ปรับความเร็วอินเตอร์เน็ต  ${NC}
echo ""
echo -e "|${GRAY} 1${NC}| เปิดใช้งานการปรับแต่งความเร็วอินเทอร์เน็ต"
echo -e "|${GRAY} 2${NC}| ปิดใช้งานการปรับแต่งความเร็วอินเทอร์เน็ต"
echo ""
read -p "เลือกหัวข้อที่ต้องการใช้งาน : " LIMITINTERNET

case $LIMITINTERNET in

	1)

echo ""
echo -e "|${GRAY} 1${NC}| Megabyte (Mbps)"
echo -e "|${GRAY} 2${NC}| Kilobyte (Kbps)"
echo ""
read -p "กรุณาเลือกหน่วยวัดความเร็วอินเทอร์เน็ต" -e PERSECOND
case $PERSECOND in
		1) 
		PERSECOND=mbit
		;;
		2) 
		PERSECOND=kbit
		;;
	esac

echo ""
echo ""
echo -e "วิธีการใส่ : เช่นต้องการให้มีความเร็ว 10Mbps ให้ใส่เลข ${GRAY}10${NC}  "
echo -e "         หากต้องการให้มีความเร็ว 512Kbps ให้ใส่เลข ${GRAY}512${NC}  "
echo ""
read -p "ใส่จำนวนความเร็วการดาวน์โหลด : " -e CHDL
read -p "ใส่จำนวนความเร็วการอัพโหลด : " -e CHUL

DNLD=$CHDL$PERSECOND
UPLD=$CHUL$PERSECOND

TC=/sbin/tc

IF="$(ip ro | awk '$1 == "default" { print $5 }')"
IP="$(ip -o ro get $(ip ro | awk '$1 == "default" { print $3 }') | awk '{print $5}')/32"     # Host IP

U32="$TC filter add dev $IF protocol ip parent 1: prio 1 u32"

    $TC qdisc add dev $IF root handle 1: htb default 30
    $TC class add dev $IF parent 1: classid 1:1 htb rate $DNLD
    $TC class add dev $IF parent 1: classid 1:2 htb rate $UPLD
    $U32 match ip dst $IP flowid 1:1
    $U32 match ip src $IP flowid 1:2
    echo ""
    echo -e "ความเร็วดาวน์โหลด ${GRAY} $CHDL$PERSECOND ${NC}"
    echo -e "ความเร็วอัพโหลด $GRAY} $CHUL$PERSECOND ${NC}"
    echo ""
    echo "เปิดใช้งานการปรับแต่งความเร็วอินเทอร์เน็ต"
    exit

	;;

	2)

TC=/sbin/tc
IF="$(ip ro | awk '$1 == "default" { print $5 }')"

    $TC qdisc del dev $IF root
    echo ""
    echo "ปิดใช้งานการปรับแต่งความเร็วอินเทอร์เน็ต"
    echo ""
    exit

	;;

esac
