Is your server Secure enough?
=============================

TCP
To disable TCP timestamps in GNU/Linux TCP/IPv4, that implement RFC1323.
````
echo 'net.ipv4.tcp_timestamps=0' >> /etc/sysctl.conf
# to apply the settings at runtime.
sysctl -p
````

NTP
Log onto your server via SSH as the root user and enter the following command replacing serverip with the IP of your server.
If the command returns a long list of IP addresses then your server is vulnerable!

````
ntpdc -n -c monlis serverip
````

RESOURCES

- https://www.cyberciti.biz/faq/linux-kernel-etcsysctl-conf-security-hardening/
- https://github.com/dmpayton/django-admin-honeypot
- https://github.com/enaqx/awesome-pentest
- https://github.com/paralax/awesome-honeypots
