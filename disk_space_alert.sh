# crontab controllo uso disco ogni giorno alle ore 8 am
# 0 8 * * * wert /home/wert/Progs/DiskFullEmail.sh

#!/bin/bash
CURRENT=$(df / | grep / | awk '{ print $5}' | sed 's/%//g')
THRESHOLD=90
EMAIL=blahblah@email.cu
FREE_RAM=$(free -m | grep Mem | awk -F' ' {'print $4'})


if [ "$CURRENT" -gt "$THRESHOLD" ] ; then
    mail -s 'Alert: Disk Space' $EMAIL << EOF
Your root partition remaining free space is critically low. Used: $CURRENT%
EOF
fi

if [ $(expr $FREE_RAM / 1024) -le 1 ]; then 
     mail -s 'Alert: Available RAM less then 1GB' $EMAIL << EOF
Current available RAM: $FREE_RAM GB
EOF
fi
