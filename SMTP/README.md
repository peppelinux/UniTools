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
