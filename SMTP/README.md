Check TLS smtp server cert

````
openssl s_client -starttls smtp -connect smtpserver.unical.it:587
````

Add in main.cf
````
smtp_tls_auth_only = no
smtp_use_tls = yes
smtp_tls_security_level = may
````

In case of error: *Our system has detected that this message does 550-5.7.1 not meet IPv6 sending guidelines regarding PTR records and 550-5.7.1 authentication. Please review 550-5.7.1  https://support.google.com/mail/?p=IPv6AuthError for more information 550 5.7.1 . k12si183374edr.58 - gsmtp (in reply to end of DATA command))*
````
nano  /etc/postfix/main.cf
# replace inet_protocols = all to inet_protocols = ipv4
service postfix restart

# verify
inet_protocols = ipv4
````
