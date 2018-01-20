Is your server Secure enough?
=============================

TCP
To disable TCP timestamps in GNU/Linux TCP/IPv4, that implement RFC1323.
````
echo 'net.ipv4.tcp_timestamps=0' >> /etc/sysctl.conf
# to apply the settings at runtime.
sysctl -p

# also remember to
net.ipv4.conf.all.log_martians=1 
net.ipv4.conf.default.log_martians=1

net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1

net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0

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
