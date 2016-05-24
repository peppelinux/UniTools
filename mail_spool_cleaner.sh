#!/bin/bash
# automatic clean your mailbox

# change it according to your path
MAIL_SPOOL_FILE="/var/spool/mail/username"

# percent
EMAIL_PERCENT_TO_PURGE=33

# count email
EMAIL_COUNT=$(grep -c "^From: " $MAIL_SPOOL_FILE )

#
EMAIL_NUMBER_TO_PURGE=$(echo $(($EMAIL_COUNT * $EMAIL_PERCENT_TO_PURGE / 100)))

# email purge
mailx -f $MAIL_SPOOL_FILE << EOF
d 1-$EMAIL_NUMBER_TO_PURGE
EOF
