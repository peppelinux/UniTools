# Firewall & Kernel IP Forwarding

# SSH bruteforce prevention
IPT=iptables
CHAIN=INPUT
SSH_PORT=22
HITCOUNT=3 # 2 syn connection (<3)
SECONDS=20 # in 20 seconds are allowed

# --rcheck: Check if the source address of the packet is  currently  in  the list.
# --update: Like  --rcheck,  except it will update the "last seen" timestamp if it matches.

$IPT -I $CHAIN -p tcp -m tcp --dport $SSH_PORT -m state --state NEW -m recent --set --name sshguys --rsource
$IPT -I $CHAIN -p tcp -m tcp --dport $SSH_PORT -m state  --state NEW  -m recent --rcheck --seconds $SECONDS --hitcount $HITCOUNT --rttl --name sshguys --rsource -j LOG --log-prefix "BLOCKED SSH (brute force)" --log-level 4 -m limit --limit 1/minute --limit-burst 5
$IPT -I $CHAIN -p tcp -m tcp --dport $SSH_PORT -m recent --rcheck --seconds $SECONDS --hitcount $HITCOUNT --rttl --name sshguys --rsource -j REJECT --reject-with tcp-reset
$IPT -I $CHAIN -p tcp -m tcp --dport $SSH_PORT -m recent --update --seconds $SECONDS --hitcount $HITCOUNT --rttl --name sshguys --rsource -j REJECT --reject-with tcp-reset
$IPT -I $CHAIN -p tcp -m tcp --dport $SSH_PORT -m state --state NEW,ESTABLISHED  -j ACCEPT

# IPSec
IPSEC_NET="10.9.8.0/24"
IPSEC_WAN_IF=eth0
STORE_PROCVAR_PERMANENTLY=1

$IPT -I INPUT -i lo -j ACCEPT

$IPT -A $CHAIN -p udp --dport  500 -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "VPN strongswan port 500"
$IPT -A $CHAIN -p udp --dport  500 -j ACCEPT

$IPT -A $CHAIN -p udp --dport 4500 -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "VPN strongswan port 4500"
$IPT -A $CHAIN -p udp --dport 4500 -j ACCEPT

# forward ESP (Encapsulating Security Payload) traffic so the VPN clients will be able to connect. 
# ESP provides additional security for our VPN packets as they're traversing untrusted networks
# not needed if: leftfirewall=yes
#$IPT -A FORWARD --match policy --pol ipsec --dir in  --proto esp -s $IPSEC_NET -j ACCEPT
#$IPT -A FORWARD --match policy --pol ipsec --dir out --proto esp -d $IPSEC_NET -j ACCEPT

# ipsec default gateways to the clients
$IPT -t nat -A POSTROUTING -s $IPSEC_NET -o $IPSEC_WAN_IF -m policy --pol ipsec --dir out -j ACCEPT
# log connections 
$IPT -t nat -A POSTROUTING -s $IPSEC_NET -o $IPSEC_WAN_IF -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "VPN outgoing: "
$IPT -t nat -A POSTROUTING -s $IPSEC_NET -o $IPSEC_WAN_IF -j MASQUERADE

# if you want to map a public pool of ip
# IP_POOL="1.97.10.0/24"
# $IPT -t nat -A PREROUTING -d $IPSEC_NET -j NETMAP --to $IP_POOL

# It prevents IP packet fragmentation on some clients, we'll tell IPTables to reduce the size of packets by adjusting the packets' maximum segment size. 
# This prevents issues with some VPN clients
$IPT -t mangle -A FORWARD --match policy --pol ipsec --dir in -s $IPSEC_NET -o $IPSEC_WAN_IF -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360

# save iptables rules
netfilter-persistent save
netfilter-persistent reload

# https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt

# configure server ipv4 behaviour
sysctl -w net.ipv4.ip_forward=1
# Do not accept ICMP redirects (prevent MITM attacks)
sysctl -w net.ipv4.conf.all.accept_redirects=0
# Do not send ICMP redirects (we are not a router)
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.ip_no_pmtu_disc=1


if [ "$STORE_PROCVAR_PERMANENTLY" -eq "1" ]; then
    echo "store procvar permanently with sed"
    
    sed -r -i 's/#?\ ?net.ipv4.ip_forward\ ?=\ ?(0|1)/net.ipv4.ip_forward=1/' /etc/sysctl.conf
    grep net.ipv4.ip_forward /etc/sysctl.conf
    
    sed -r -i 's/#?\ ?net.ipv4.conf.all.accept_redirects\ ?=\ ?(0|1)/net.ipv4.conf.all.accept_redirects=0/' /etc/sysctl.conf
    grep net.ipv4.conf.all.accept_redirects /etc/sysctl.conf

    sed -r -i 's/#?\ ?net.ipv4.conf.all.send_redirects\ ?=\ ?(0|1)/net.ipv4.conf.all.send_redirects=0/' /etc/sysctl.conf 
    grep net.ipv4.conf.all.send_redirects /etc/sysctl.conf

    #~ sed -r -i 's/#?\ ?net.ipv4.ip_no_pmtu_disc\ ?=\ ?(0|1)/net.ipv4.ip_no_pmtu_disc=0/' /etc/sysctl.conf
    #~ grep net.ipv4.ip_no_pmtu_disc /etc/sysctl.conf
    
    # test if the latests exists or append it
    grep -q '^#?\ ?net.ipv4.ip_no_pmtu_disc' /etc/sysctl.conf && \
    sed -r -i 's/#?\ ?net.ipv4.ip_no_pmtu_disc\ ?=\ ?(0|1)/net.ipv4.ip_no_pmtu_disc=1/' /etc/sysctl.conf || \
    echo 'net.ipv4.ip_no_pmtu_disc=1' >> /etc/sysctl.conf
    
    grep net.ipv4.ip_no_pmtu_disc /etc/sysctl.conf

fi
