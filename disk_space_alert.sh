# crontab controllo uso disco ogni giorno alle ore 8 am
# 0 8 * * * wert /home/wert/Progs/DiskFullEmail.sh

#!/bin/bash
CURRENT=$(df / | grep / | awk '{ print $5}' | sed 's/%//g')
THRESHOLD=90
EMAIL=blahblah@email.cu

if [ "$CURRENT" -gt "$THRESHOLD" ] ; then
    mail -s 'Disk Space Alert' $EMAIL << EOF
Your root partition remaining free space is critically low. Used: $CURRENT%
EOF
fi
