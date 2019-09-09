Setup
-----
This configuration notifies ssh user accesses in realtime, though an email notifications.

````
apt install bsd-mailx postfix
````

configure postfix as internet site, then add in `/etc/postfix/main.cf` the following
````
relayhost = [smtphostname.unical.it]:587
smtp_tls_auth_only = no
smtp_use_tls = yes
smtp_tls_security_level = may
````

Append the following code in `/etc/profile`
````
if [ -n "$SSH_CLIENT" ]; then 
    TEXT="$(date): ssh login to ${USER}@$(hostname -f)" 
    TEXT="$TEXT from $(echo $SSH_CLIENT|awk '{print $1}')" 
    echo $TEXT|mail -s "ssh login" sysadmin1@unical.it -c sysadmin2@unical.it
fi
````
