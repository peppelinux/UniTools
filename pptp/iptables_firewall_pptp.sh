#!/bin/sh

###########################
# Imposto alcune variabili
###########################

# Il path di $IPT
IPT="/sbin/iptables"
IPTABLES=$IPT

# Interfaccia wan
PUB_IF=eno1


MYNET1=10.64.220.0/30
MYNODE1=10.64.220.214

IFS=','
TRUSTED_NODES=10.12.12.222,10.12.12.223 #,100.102.0.99,100.102.0.100
TRUSTED_IF=pptp_smc+,pptp_cesmma+

# smc tunnel
TRUSTED_NETWORK_1=100.102.0.0/24

SSH_PORT=22

# nota 224.0.0.0 è igmp multicast :)
FAKE_NODES=10.0.0.0/8,\
169.254.0.0/16,\
172.16.0.0/12,\
127.0.0.0/8,\
224.0.0.0/4,\
240.0.0.0/5,\
0.0.0.0/8,\
239.255.255.0/24,\
255.255.255.255



########################
# Un messaggio di avvio
########################

echo " Loading $IPT rules..."
echo " My net is: $MYNET1"
echo " My node is: $MYNODE1"
echo " My trusted nodes are: $TRUSTED_NODES"
echo " loading.."
echo ""
modprobe ip_conntrack_ftp
modprobe nf_conntrack_pptp
modprobe nf_conntrack_proto_gre


#####################################
# Pulisco la configurazione corrente
#####################################

# Cancellazione delle regole presenti nelle chains
$IPT -F
#$IPT -F -t nat

# Eliminazione delle chains non standard vuote
$IPT -X

##############################
# Creo le mie chains
##############################

$IPT -N INDESIDERATI
$IPT -N ICMP
$IPT -N PORTSCANNERS
$IPT -N UDP
$IPT -N TCP_SERVICES

##############################
# Abilito il traffico locale
##############################

$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT
$IPT -A INPUT -s $MYNODE1 -j ACCEPT

# priorità per le connessioni  in corso...
$IPT -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT



##############################
# connessioni relative e da nodi amici passano purchè abbiamo passato i test e siano innoque
##############################
for i in $TRUSTED_NODES; do $IPT -A INPUT -s $i -j ACCEPT; done

# Accept all packets via ppp* interfaces (for example, ppp0)
#iptables -A INPUT -i $TRUSTED_IF -j ACCEPT
#iptables -A OUTPUT -o $TRUSTED_IF -j ACCEPT

for i in $TRUSTED_IF; do $IPT -A INPUT -i $i -j ACCEPT; $IPT -A OUTPUT -o $i -j ACCEPT; done


##############################
# pacchetti contraffatti
##############################
#$IPT -A INPUT   -m state --state INVALID -j DROP
#$IPT -A FORWARD -m state --state INVALID -j DROP
#$IPT -A OUTPUT  -m state --state INVALID -j DROP



##############################
# evitiamo i soliti ingoti ...
##############################
#$IPT -A INPUT -j INDESIDERATI
for i in $FAKE_NODES; do
$IPT -A INDESIDERATI  -s $i  -j DROP
$IPT -A INDESIDERATI  -d $i -j DROP; 
done

##############################
# evitiamo i pacchetti ideati per farmi dannare
##############################
echo "DoS filters"
#$IPT -A INPUT -p tcp -m tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
#$IPT -A INPUT -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP

# forse
#~ $IPT -A INPUT -p tcp        --tcp-flags ALL ACK,RST,SYN,FIN -j DROP
#~ $IPT -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
#~ $IPT -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# problematico
#$IPT -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j DROP

$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL ALL -j DROP
 
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL NONE -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "NULL Packets"
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL NONE -j DROP # NULL packets
 
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
 
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags SYN,FIN SYN,FIN -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "XMAS Packets"
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP #XMAS
 
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags FIN,ACK FIN -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "Fin Packets Scan"
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags FIN,ACK FIN -j DROP # FIN packet scans
 
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

# e ancora
iptables -A INPUT -i ${PUB_IF} -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
iptables -A INPUT -i ${PUB_IF} -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -A INPUT -i ${PUB_IF} -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A INPUT -i ${PUB_IF} -p tcp -m tcp --tcp-flags FIN,RST FIN,RST -j DROP
iptables -A INPUT -i ${PUB_IF} -p tcp -m tcp --tcp-flags FIN,ACK FIN -j DROP
iptables -A INPUT -i ${PUB_IF} -p tcp -m tcp --tcp-flags ACK,URG URG -j DROP

##############################
# evitiamo gli attacchi smurf che disconnettono tutto da tutti
##############################
echo "SmUrF filters"
$IPT -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT
$IPT -A INPUT -p tcp -m tcp --tcp-flags RST RST             -j DROP


# ICMP
echo "ICMP filters"
$IPT -A INPUT -p ICMP -j ICMP
#$IPT -A ICMP -p icmp --icmp-type echo-reply   -m limit --limit  1/s --limit-burst 1 -j ACCEPT
#$IPT -I ICMP 1 -p icmp --icmp-type 8 -m limit --limit  1/s --limit-burst 1 -j ACCEPT

# fondamentalmente sono un signore: accetto tutto purchè non facciano flood, 2 al secondo.
$IPT -A ICMP -p icmp -m limit --limit  1/s --limit-burst 2 -j ACCEPT
$IPT -A ICMP -j DROP


# filtro sugli UDP
echo "UDP filters"
$IPT -A INPUT -p udp -j UDP
$IPT -A UDP -p udp --sport 53 -j ACCEPT
# accetto solo di parlare con un DNS
$IPT -A UDP -p udp -j DROP


##############################
# Tento di isolare i portscans in una chain per gestirle ad-hoc
# tutte le connessioni UDP/TCP le tratto con un burst, se questo venisse superato: LOGGO e DROPPO, è un portscan !
# dopo un limit/burst seguono 20 minuti di buio totale
##############################
echo "Portscanner filters"

$IPT -A INPUT -j PORTSCANNERS
# burst ampio
$IPT -A PORTSCANNERS  -j LOG --log-prefix "CONNECTION " --log-level 4 -m limit --limit 4/s --limit-burst 1
# sperimentale
#$IPT -A PORTSCANNERS  -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j RETURN
#$IPT -A PORTSCANNERS  -j DROP


# inizio porte riservate Servizi
echo "TCP filters"

$IPT -A INPUT -p tcp  -j TCP_SERVICES

# SERVIZI
#$IPT -A TCP_SERVICES -p tcp -m tcp --dport 25 -j ACCEPT
$IPT -A TCP_SERVICES -p tcp -m tcp --dport 80 -j ACCEPT
#$IPT -A TCP_SERVICES -p tcp -m tcp --dport 21 -j ACCEPT
$IPT -A TCP_SERVICES -p tcp -m tcp --dport 8080 -j LOG --log-prefix "incoming 8080 CONNECTION " --log-level 4 -m limit --limit 1/second --limit-burst 1
$IPT -A TCP_SERVICES -p tcp -m tcp --dport 8080 -j ACCEPT

# Accept incoming connections to port 1723 (PPTP) massimo 10 connessioni in 5 minuti
#iptables -A TCP_SERVICES -p tcp --dport 1723 -m state --state NEW,ESTABLISHED -m recent --set -j ACCEPT
#iptables -A TCP_SERVICES -p tcp --dport 1723 -m state --state NEW -m recent --name pptpguys --update --seconds 300 --hitcount 11 -j DROP

$IPT -A TCP_SERVICES -p tcp --dport 1723 -m recent --rcheck --seconds 11 --hitcount 11 --name PPTP -j LOG --log-prefix "PPTP BRUTEFORCE"
$IPT -A TCP_SERVICES -p tcp --dport 1723 -m recent --update --seconds 11 --hitcount 11 --name PPTP -j DROP
$IPT -A TCP_SERVICES -p tcp --dport 1723 -m state --state NEW -m recent --set --name PPTP -j ACCEPT
$IPT -A TCP_SERVICES  -i $PUB_IF -m state --state ESTABLISHED,RELATED -j ACCEPT

# Accept GRE packets per PPTP
iptables --insert OUTPUT 1 \
--source 0.0.0.0/0.0.0.0 \
--destination 0.0.0.0/0.0.0.0 \
--jump ACCEPT --protocol gre \
--out-interface $PUB_IF

iptables --insert INPUT 29 \
--source 0.0.0.0/0.0.0.0 \
--destination 0.0.0.0/0.0.0.0 \
--jump ACCEPT --protocol gre \
--in-interface $PUB_IF


# in ssh accettiamo max 10 connessioni ogni 2 minuti
#$IPT -A TCP_SERVICES -p tcp --dport $SSH_PORT -m state --state NEW -m recent --name sshguys  --update --seconds 120 --hitcount 11 -j DROP
#$IPT -A TCP_SERVICES -p tcp -s 0/0  --dport $SSH_PORT -m state --state NEW,ESTABLISHED -m recent --name sshguys --set -j ACCEPT

echo "SSH limit"
# max 10 connections in 5 minutes
#$IPT -A TCP_SERVICES -p tcp --dport 22 -m state --state NEW,ESTABLISHED -m recent --set --rsource -j ACCEPT
#$IPT -A TCP_SERVICES -m recent --update --seconds 300 --hitcount 11 --name sshguys --rsource -j LOG --log-prefix "Anti SSH-Bruteforce: " --log-level 6 
#$IPT -A TCP_SERVICES -p tcp --dport 22 -m state --state NEW -m recent --name sshguys --update --seconds 300 --hitcount 11 -j DROP
#$IPT -A OUTPUT -p tcp -s $MYNODE1 -d 0/0 --sport 22  -m state --state ESTABLISHED -j ACCEPT


#Line 1 of the script checks if the source IP has already marked as 'Bad Guy' and logs the packet, if so. 
#The second line drops the packet if it comes from a marked IP address and marks the source again. 
#This ensures that the source will stay blacklisted as long as the attack continues. 
#The third line marks the source IP as 'Bad Guy' if there are more than 2 connection attempts per minute. 
#Note that already established connections continue to work (because the packets will no more arriving on 22).
$IPT -A TCP_SERVICES -p tcp --dport 22 -m recent --rcheck --seconds 60 --hitcount 3 --name SSH -j LOG --log-prefix "SSH BRUTEFORCE "
$IPT -A TCP_SERVICES -p tcp --dport 22 -m recent --update --seconds 60 --hitcount 3 --name SSH -j DROP
$IPT -A TCP_SERVICES -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH -j ACCEPT
$IPT -A TCP_SERVICES  -i $PUB_IF -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "RaNdOm rules"
# loggo a caso connessioni di porte usate spesso dai portscanners
$IPT -A TCP_SERVICES -p tcp -m tcp --dport 5190 -j LOG --log-prefix "Connessione su PORTA rAnDoM molto strana (NMAP ?)" --log-level 4 -m limit --limit 1/second --limit-burst 1
$IPT -A TCP_SERVICES -p tcp -m tcp --dport 1863 -j LOG --log-prefix "Connessione su PORTA rAnDoM molto strana (NMAP ?)" --log-level 4 -m limit --limit 1/second --limit-burst 1


##############################
# Infine mando tutto a quel paese
##############################
$IPT -A INPUT -j REJECT

#$IPT -A SERVICES -p tcp -m tcp --dport 443 -j ACCEPT
#$IPT -A SERVICES -p tcp -m tcp --dport 631 -j DROP
#$IPT -A SERVICES -p tcp -m tcp --dport 995 -j DROP

#samba
#$IPT -A SERVICES -p tcp -m tcp --dport 139 -j DROP
#$IPT -A SERVICES -p tcp -m tcp --dport 137 -j DROP
#$IPT -A SERVICES -p tcp -m tcp --dport 138 -j DROP
#$IPT -A SERVICES -p tcp -m tcp --dport 445 -j DROP
# portmap
#$IPT -A SERVICES -p tcp -m tcp --dport 111 -j DROP

# postgresql
#$IPT -A SERVICES -p tcp -m tcp --dport 5432 -j DROP

$IPT -A OUTPUT -p icmp --icmp-type echo-request  -m limit --limit  1/s --limit-burst 1 -j ACCEPT
#$IPT -A OUTPUT  -s $FAKE_NODES  -j DROP
#$IPT -A OUTPUT  -d $FAKE_NODES  -j DROP


echo "Forward rules"
$IPT -A FORWARD -d 255.255.255.255 -j DROP
$IPT -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

for i in $(echo $TRUSTED_IF | sed "s/,/ /g"); 
do 
    for e in $(echo $TRUSTED_NODES | sed "s/,/ /g"); 
    do 
    $IPT -A FORWARD -s $e -o $i -j ACCEPT; 
    done;    
    $IPT -A FORWARD -s $TRUSTED_NETWORK_1 -o $i -j ACCEPT; 
    
done


for i in $TRUSTED_IF; do $IPT -A FORWARD -s $MYNODE1 -o $i -j ACCEPT; done

# forward verso lao_smc
#$IPT -A FORWARD -s 10.12.12.222 -o ppp0 -j ACCEPT

$IPT -A FORWARD -j DROP

# NAT
$IPT -t nat -F
$IPT -t nat -X

#$IPT -t nat -A POSTROUTING -s 10.12.12.21 -d 172.31.10.0/24 -o tun0 -j MASQUERADE


#  LAO_SMC routing
#$IPT -t nat -A POSTROUTING -s 10.12.12.222  -d 192.168.21.0/24 -o ppp0 -j MASQUERADE
#$IPT -t nat -A POSTROUTING -s 10.12.12.222 -d 100.102.0.1/32  -o ppp0 -j MASQUERADE


# - Abilitare limite di 7 secondi tra un'autorizzazione e l'altra da una stessa sorgente
#$$IPT -A INPUT -p tcp -m state --state NEW --dport 22 -m recent --update --seconds 7 -j DROP
#$$IPT -A INPUT -p tcp -m state --state NEW --dport 22 -m recent --set -j ACCEPT

#STUFFS 
SYSCTL=/sbin/sysctl
$SYSCTL -w net.ipv4.tcp_syncookies=1
$SYSCTL -w net.ipv4.tcp_fin_timeout=10
$SYSCTL -w net.ipv4.ip_forward=1
#sysctl  net.ipv4.conf.ppp0.forwarding=1
$SYSCTL -w net.ipv4.conf.all.log_martians=1
$SYSCTL -w net.ipv4.conf.default.accept_source_route=0
$SYSCTL -w net.ipv4.conf.default.accept_redirects=0
$SYSCTL -w net.ipv4.conf.default.secure_redirects=0
$SYSCTL -w net.ipv4.icmp_echo_ignore_broadcasts=1
#net.ipv4.icmp_ignore_bogus_error_messages = 1
$SYSCTL -w net.ipv4.tcp_syncookies=1
$SYSCTL -w net.ipv4.conf.all.rp_filter=1
$SYSCTL -w net.ipv4.conf.default.rp_filter=1

