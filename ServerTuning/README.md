dotazione iniziale
-----
````
apt update && apt upgrade
apt install htop iotop atop hdparm ioping iozone

apt install build-essential python3-dev ipython python3-pip libssl-dev htop sudo nmap tcpdump nftables adduser net-tools git
pip3 install virtualenv uwsgi

nano /etc/hostname
nano /etc/sshd
nano /etc/hosts

USER=
adduser $USER

addgroup $USER sudo

deluser operatore

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
