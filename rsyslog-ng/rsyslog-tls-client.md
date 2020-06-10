
````
apt install rsyslog rsyslog-gnutls
rsyslogd -v
````

In /etc/rsyslog.d/log.unical.it.conf provides UDP syslog reception

````
# CA crt
$DefaultNetstreamDriverCAFile /etc/ssl/certs/ca-certificates.crt

# TLS
$DefaultNetstreamDriver gtls
$ActionSendStreamDriverAuthMode anon
$ActionSendStreamDriverMode 1

#$ModLoad imtcp
#auth.* @@log.unical.it:6516

$ModLoad imudp
auth.* @log.unical.it:6516

# local queue
$ActionQueueFileName queue
$ActionQueueMaxDiskSpace 1g
$ActionQueueSaveOnShutdown on
$ActionQueueType LinkedList
$ActionResumeRetryCount -1
````
