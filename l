#!/bin/bash

if [ ! -f /usr/local/bin/Deleted-Account ]; then
    echo "echo "รายชื่อบัญชีที่หมดอายุแล้ว"" > /usr/local/bin/Deleted-Account
    echo "echo " "" > /usr/local/bin/Deleted-Account
	chmod +x /usr/local/bin/Deleted-Account
fi

TODAY=`date +%d-%m-%Y`

cat /etc/shadow | cut -d: -f1,8 | sed /:$/d > /usr/local/bin/Expire-List
TOTALACCOUNTS=`cat /usr/local/bin/Expire-List | wc -l`

for((i=1; i<=$TOTALACCOUNTS; i++ ))
       do
       USERNAMEWILLEXPIRE=`head -n $i /usr/local/bin/Expire-List | tail -n 1`
       USERNAME=`echo $USERNAMEWILLEXPIRE | cut -f1 -d:`
       USEREXP=`echo $USERNAMEWILLEXPIRE | cut -f2 -d:`
       USEREXPIREINSECONDS=$(( $USEREXP * 86400 ))
       DATEEXP=`date -d @$USEREXPIREINSECONDS`
       DATE=`echo $DATEEXP |awk -F" " '{print $3}'`
       while [ ${#DATE} -lt 2 ]
       do
           DATE="0"$DATE
       done

       while [ ${#username} -lt 15 ]
       do
           username=$username" " 
       done
       MOUNTYEAR=`echo $DATEEXP | awk -F" " '{print $2,$6}'`
       TODAYTIME=`date +%s`
       if [ $USEREXPIREINSECONDS -ge $TODAYTIME ] ;
           then
			:
       else
       echo "echo "ชื่อบัญชี $USERNAME หมดอายุในวันที่ $DATE $MOUNTYEAR และถูกลบออกจากระบบเมื่อวันที่ $TODAY "" >> /usr/local/bin/Deleted-Account
       userdel $username
       fi
done
