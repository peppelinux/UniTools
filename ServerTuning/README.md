dotazione iniziale
-----
````
apt update && apt upgrade -y
apt install htop iotop atop hdparm ioping iozone

apt install unattended-upgrades apt-listchanges logrotate ntp

apt install build-essential python3-dev python3-pip libssl-dev htop sudo nmap tcpdump nftables adduser net-tools git iptables-persistent
pip3 install virtualenv uwsgi ipython

nano /etc/hostname
nano /etc/ssh/sshd_config
nano /etc/hosts

nano /etc/ntp.conf
# inserire
pool ntp.unical.it iburst
interface ignore wildcard
interface listen 127.0.0.1


USER=
/usr/sbin/adduser $USER

/usr/sbin/addgroup $USER sudo
/usr/sbin/deluser operatore

apt clean

# also sysctl tweak: depending by server usage.


# if netinst breaks the balls with locales...
LOCALE="it_IT.UTF-8"

cat <<EOF > /etc/default/locale
LANGUAGE=$LOCALE,
LC_ALL=$LOCALE,
LC_ADDRESS=$LOCALE,
LC_NAME=$LOCALE,
LC_MONETARY=$LOCALE,
LC_PAPER=$LOCALE,
LC_IDENTIFICATION=$LOCALE,
LC_TELEPHONE=$LOCALE,
LC_MEASUREMENT=$LOCALE,
LC_TIME=$LOCALE,
LC_NUMERIC=$LOCALE,
LANG=$LOCALE
EOF

````

notifica accessi ssh via email
````
https://github.com/peppelinux/UniTools/blob/master/SMTP/ssh_login_notification.md
````

analisi prestazioni dischi
--------------------------
````
hdparm -Tt /dev/sda
ioping . -c 5
iozone -e -I -a -s 10M -r 4k -i 0 -i 1 -i 2
````

consigli
--------
il kernel di linux impone dei limit sugli FD, è possibile che i numeri che ci hai descritto sforino le soglie stabilite in
`/etc/security/limits.conf`

come riportato da
`ulimit -aH`

Valuta quindi il numero massimo di connessioni consentite e le politiche di uso e rilascio delle risorse relative ai tcp_wrappers.
Parametri da consultare relativi al linux kernel potrebbero in aggiunta essere:

````
sysctl net.ipv4.tcp_fin_timeout = 60
net.ipv4.ip_local_port_range = 32768   61000
````

esempio classico della configurazione standard che non consente più di
(61000 - 32768) / 60 = 470 socket al secondo

poi somaxconn ci dice che non sono consentite più di 1024 connessioni per ogni socket di sistema
`sysctl net.core.somaxconn=128`

...default è 128, puoi serenamente portare la soglia a 1024.

solimente innalzo anche questi:
````
sysctl net.core.netdev_max_backlog=1000
sysctl net.ipv4.tcp_max_syn_backlog=1024
````

utile controllare anche questi
````
kernel.shmmax=18446744073692774399 for 64-bit
kernel.msgmni=1024
fs.file-max=8192
kernel.sem=”250 32000 32 1024″
````

sysctl server template
----------------------

````
net.ipv4.ip_local_port_range=1025 65435

net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_adv_win_scale=1
net.ipv4.tcp_low_latency=1

net.ipv4.tcp_timestamps=0 
net.ipv4.tcp_tw_reuse=1 
net.ipv4.tcp_tw_recycle=1 
net.ipv4.tcp_keepalive_time=1800 

net.ipv4.tcp_rmem=4096 87380 8388608
net.ipv4.tcp_wmem=4096 87380 8388608

net.ipv4.tcp_fin_timeout=10

net.core.somaxconn=10000
net.ipv4.tcp_max_syn_backlog=10000

# If the option is set, we conform to RFC 1337 and drop RST packets, preventing TIME-WAIT Assassination
net.ipv4.tcp_rfc1337=1

net.ipv4.tcp_max_tw_buckets=1440000

# 0 tells the kernel to avoid swapping processes out of physical memory
# for as long as possible
# 100 tells the kernel to aggressively swap processes out of physical memory
# and move them to swap cache
vm.swappiness=0

# CoDel works by looking at the packets at the head of the queue — those which have been through the entire queue and are about to be transmitted.
# If they have been in the queue for too long, they are simply dropped
net.core.default_qdisc=fq_codel

# disables RFC 2861 behavior and time out the congestion window without an idle period
net.ipv4.tcp_slow_start_after_idle=0

# SACK ping of death patch
net.ipv4.tcp_sack=0

# then
# sysctl -p
````

Benchmarks
----------

Httpd, 1000 connessioni concorrenti con keep-alive di 60 secondi.
````
ab -kc 1000 -t 60 https://thathost.unical.it/idp/shibboleth
````

Httpd, 1000 connessioni permanenti con 5000 requests per connessione.
````
ab -n 5000 -c 1000  https://proxy.auth.unical.it/spidSaml2/metadata
````

