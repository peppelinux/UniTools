#!/bin/bash
# in crontab
# */1  * * * * root bash /etc/ppp/pptp_lao.cron_autorestart.sh >> /var/log/ppp.log 2>&1

HOST=100.102.0.1
PEER_NAME=lao_smc

DATE=`date`
PINGRES=`ping -c 2 $HOST`
PLOSS=`echo $PINGRES : | grep -oP '\d+(?=% packet loss)'`
echo "$DATE : Loss Result : $PLOSS"
 
if [ "100" -eq "$PLOSS" ];
then
    echo "$DATE : Starting : $HOST"
    #/usr/sbin/pptp pty file /etc/ppp/options.pptp user $PPTPUSER password $PPTPPASS
    /usr/bin/pon $PEER_NAME
    echo "$DATE : Now running : $HOST"
else
    echo "$DATE : Already running : $HOST"
fi

