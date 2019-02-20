tools
-----
`apt install htop iotop atop hdparm ioping iozone`

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
