
````
apt install rsyslog rsyslog-gnutls
rsyslogd -v
````

Create the CA chain
````
cat DigiCertAssuredIDRootCA.pem  TERENA_SSL_CA_3.pem > /etc/rsyslog.d/ca.d/ca.crt
````

Test that the built CA chain is valid
````
openssl s_client -connect log.unical.it:6516 -showcerts -CAfile /etc/rsyslog.d/ca.d/ca.crt 
````

In /etc/rsyslog.d/log.unical.it.conf provides UDP syslog reception

````
# CA crt
$DefaultNetstreamDriverCAFile /etc/rsyslog.d/ca.d/ca-certificates.crt
#$DefaultNetstreamDriverCertFile /etc/ssl/rsyslog/CLIENT-cert.pem
#$DefaultNetstreamDriverKeyFile /etc/ssl/rsyslog/CLIENT-key.pem

# TLS
$DefaultNetstreamDriver gtls
$ActionSendStreamDriverAuthMode anon
$ActionSendStreamDriverMode 1

$ModLoad imtcp
auth.* @@log.unical.it:6516

#$ModLoad imudp
#auth.* @log.unical.it:6516

# local queue
$ActionQueueFileName queue
$ActionQueueMaxDiskSpace 1g
$ActionQueueSaveOnShutdown on
$ActionQueueType LinkedList
$ActionResumeRetryCount -1
````
