#!/bin/bash

DATE1=$(vnstat -h | sed -n '16p' | awk '{print $1}')
RX1=$(vnstat -h | sed -n '16p' | awk '{print $2}' | cut -d ',' -f 1-20 --output-delimiter='')
TX1=$(vnstat -h | sed -n '16p' | awk '{print $3}' | cut -d ',' -f 1-20 --output-delimiter='')
CONRX1=$(echo "scale=2;$RX1 / 1000000" | bc)
CONTX1=$(echo "scale=2;$TX1 / 1000000" | bc)

DATE2=$(vnstat -h | sed -n '17p' | awk '{print $1}')
RX2=$(vnstat -h | sed -n '17p' | awk '{print $2}' | cut -d ',' -f 1-20 --output-delimiter='')
TX2=$(vnstat -h | sed -n '17p' | awk '{print $3}' | cut -d ',' -f 1-20 --output-delimiter='')
CONRX2=$(echo "scale=2;$RX2 / 1000000" | bc)
CONTX2=$(echo "scale=2;$TX2 / 1000000" | bc)

DATE3=$(vnstat -h | sed -n '18p' | awk '{print $1}')
RX3=$(vnstat -h | sed -n '18p' | awk '{print $2}' | cut -d ',' -f 1-20 --output-delimiter='')
TX3=$(vnstat -h | sed -n '18p' | awk '{print $3}' | cut -d ',' -f 1-20 --output-delimiter='')
CONRX3=$(echo "scale=2;$RX3 / 1000000" | bc)
CONTX3=$(echo "scale=2;$TX3 / 1000000" | bc)

DATE4=$(vnstat -h | sed -n '19p' | awk '{print $1}')
RX4=$(vnstat -h | sed -n '19p' | awk '{print $2}' | cut -d ',' -f 1-20 --output-delimiter='')
TX4=$(vnstat -h | sed -n '19p' | awk '{print $3}' | cut -d ',' -f 1-20 --output-delimiter='')
CONRX4=$(echo "scale=2;$RX4 / 1000000" | bc)
CONTX4=$(echo "scale=2;$TX4 / 1000000" | bc)

DATE5=$(vnstat -h | sed -n '20p' | awk '{print $1}')
RX5=$(vnstat -h | sed -n '20p' | awk '{print $2}' | cut -d ',' -f 1-20 --output-delimiter='')
TX5=$(vnstat -h | sed -n '20p' | awk '{print $3}' | cut -d ',' -f 1-20 --output-delimiter='')
CONRX5=$(echo "scale=2;$RX4 / 1000000" | bc)
CONTX5=$(echo "scale=2;$TX4 / 1000000" | bc)

DATE6=$(vnstat -h | sed -n '21p' | awk '{print $1}')
RX6=$(vnstat -h | sed -n '21p' | awk '{print $2}' | cut -d ',' -f 1-20 --output-delimiter='')
TX6=$(vnstat -h | sed -n '21p' | awk '{print $3}' | cut -d ',' -f 1-20 --output-delimiter='')
CONRX6=$(echo "scale=2;$RX6 / 1000000" | bc)
CONTX6=$(echo "scale=2;$TX6 / 1000000" | bc)

DATE7=$(vnstat -h | sed -n '22p' | awk '{print $1}')
RX7=$(vnstat -h | sed -n '22p' | awk '{print $2}' | cut -d ',' -f 1-20 --output-delimiter='')
TX7=$(vnstat -h | sed -n '22p' | awk '{print $3}' | cut -d ',' -f 1-20 --output-delimiter='')
CONRX7=$(echo "scale=2;$RX7 / 1000000" | bc)
CONTX7=$(echo "scale=2;$TX7 / 1000000" | bc)


DATE8=$(vnstat -h | sed -n '23p' | awk '{print $1}')
RX8=$(vnstat -h | sed -n '23p' | awk '{print $2}' | cut -d ',' -f 1-20 --output-delimiter='')
TX8=$(vnstat -h | sed -n '23p' | awk '{print $3}' | cut -d ',' -f 1-20 --output-delimiter='')
CONRX8=$(echo "scale=2;$RX8 / 1000000" | bc)
CONTX8=$(echo "scale=2;$TX8 / 1000000" | bc)


printf "%-5s %-5s %-5s %-2s\n" "วันที่" "รับข้อมูล" "ส่งข้อมูล" "หน่วยวัดขนาดปริมาณ"
echo ""
printf "%-5s %-5s %-5s %-2s\n" "$DATE1" "$CONRX1" "$CONTX1" "Gb"
printf "%-5s %-5s %-5s %-2s\n" "$DATE2" "$CONRX2" "$CONTX2" "Gb"
printf "%-5s %-5s %-5s %-2s\n" "$DATE3" "$CONRX3" "$CONTX3" "Gb"
printf "%-5s %-5s %-5s %-2s\n" "$DATE4" "$CONRX4" "$CONTX4" "Gb"
printf "%-5s %-5s %-5s %-2s\n" "$DATE5" "$CONRX5" "$CONTX5" "Gb"
printf "%-5s %-5s %-5s %-2s\n" "$DATE6" "$CONRX6" "$CONTX6" "Gb"
printf "%-5s %-5s %-5s %-2s\n" "$DATE7" "$CONRX7" "$CONTX7" "Gb"
printf "%-5s %-5s %-5s %-2s\n" "$DATE8" "$CONRX8" "$CONTX8" "Gb"
exit
