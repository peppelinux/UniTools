 # ___ ____  ____  _____ ____ 
# |_ _|  _ \/ ___|| ____/ ___|
 # | || |_) \___ \|  _|| |    
 # | ||  __/ ___) | |__| |___ 
# |___|_|   |____/|_____\____|

set -e
set -x

# ip or hostname of the server
SERVER_HOST="vpn12.unical.it"
VPN_NET="10.9.8.0/24"
VPN_DNS="10.9.8.1"

# CA setup
BUILD_CA_CERTS="0"
CA_BASEDIR="/opt"
CA_DIRNAME="CA-ipsec"
CA_PATH=$CA_BASEDIR/$CA_DIRNAME
CA_CN="$SERVER_HOST"
CA_DN="C=IT, O=UNICAL, CN=$SERVER_HOST"
RSA_BIT=4096
CERT_LIFETIME=3650

SERVER_CA_CERT="server-root-ca.pem" # pub key in cert
SERVER_CA_KEY="server-root-key.pem" # private key
SERVER_CERT="vpn-server-cert.pem"
SERVER_KEY="vpn-server-key.pem"

# purge olds if needed
# apt-get purge *strongswan*
# apt-get purge *charon*

apt-get install aptitude
aptitude install strongswan moreutils iptables-persistent

# ubuntu 16
# aptitude install strongswan-plugin-eap-mschapv2

# debian 9
# aptitude install strongswan-pki libcharon-extra-plugins strongswan-ikev2 strongswan-swanctl 

if [ "$BUILD_CA_CERTS" -eq "1" ]; then

    # CA, an IKEv2 server requires a certificate to identify itself to clients.
    if [ -d "$CA_PATH" ]; then
        mv $CA_PATH $CA_PATH.$(date +"%Y-%m-%d.%H:%M")
    fi
    
    mkdir $CA_PATH && cd $CA_PATH
    
    ipsec pki --gen --type rsa --size $RSA_BIT --outform pem > $CA_PATH/$SERVER_CA_KEY
    chmod 600 $CA_PATH/$SERVER_CA_KEY
    
    # You can change the distinguished name (DN) values, such as country, 
    # organization, and common name, to something else to if you want to.
    ipsec pki --self --ca --lifetime $CERT_LIFETIME \
    --in $CA_PATH/$SERVER_CA_KEY \
    --type rsa --dn "$CA_DN" \
    --outform pem > $CA_PATH/$SERVER_CA_CERT
    # Later, we'll copy the root certificate (server-root-ca.pem) to our client devices so they can verify the authenticity of the server when they connect
    # This is the Root Certificate of your Certificate Authority (CA). It can be downloaded from web or exported from system keychain.
    
    # Server Identity signed with our CA
    ipsec pki --gen --type rsa --size $RSA_BIT --outform pem > $CA_PATH/$SERVER_KEY
    
    ipsec pki --pub --in $CA_PATH/$SERVER_KEY \
    --type rsa | ipsec pki --issue --lifetime $CERT_LIFETIME \
    --cacert $CA_PATH/$SERVER_CA_CERT \
    --cakey $CA_PATH/$SERVER_CA_KEY \
    --dn "$CA_DN" \
    --san $CA_CN \
    --flag serverAuth --flag ikeIntermediate \
    --outform pem > $CA_PATH/$SERVER_CERT
    
    # ipsec setup
    cp $CA_PATH/$SERVER_CERT /etc/ipsec.d/certs/
    cp $CA_PATH/$SERVER_KEY /etc/ipsec.d/private/
    
    # ipsec listcacerts
    cp $CA_PATH/$SERVER_CA_CERT /etc/ipsec.d/cacerts/

    chown root /etc/ipsec.d/private/*
    chgrp root /etc/ipsec.d/private/*
    chmod -R 600 /etc/ipsec.d/private/

fi

# Strongswan setup
# backupit first
mv /etc/ipsec.conf /etc/ipsec.conf.$(date +"%Y-%m-%d.%H:%M")
cp -R /etc/ipsec.d /etc/ipsec.d.$(date +"%Y-%m-%d.%H:%M")
cp -R /etc/ipsec.secrets /etc/ipsec.secrets.$(date +"%Y-%m-%d.%H:%M")    

# strongswan setup
echo "
config setup
  # charondebug=\"all\"
  #charondebug=\"cfg 2, dmn 2, ike 2, net 2, lib 2\"
  charondebug=\"ike 1, knl 1, cfg 0\"
  # permits multiple clients with the same id
  uniqueids=no
  # strictcrlpolicy=no

# Default configuration options, used below if an option is not specified.
# See: https://wiki.strongswan.org/projects/strongswan/wiki/ConnSection
conn %default
  # Use IKEv2 by default
  keyexchange=ikev2
  # dead-peer detection to clear any \"dangling\" connections in case the client unexpectedly disconnects
  dpdaction=clear
  
  # If the tunnel has no traffic for this long (default 30 secs), Charon will send a dead peer detection packet. The value 0 means to not send such packets, relying on ordinary traffic, which will occur at least once an hour, which is the default rekeying lifetime.
  dpddelay=30s
  
  # Do not renegotiate a connection if it is about to expire
  rekey=no
  
  # Prefer modern cipher suites that allow PFS (Perfect Forward Secrecy)
  ike=aes128-sha256-ecp256,aes256-sha384-ecp384,aes128-sha256-modp2048,aes128-sha1-modp2048,aes256-sha384-modp4096,aes256-sha256-modp4096,aes256-sha1-modp4096,aes128-sha256-modp1536,aes128-sha1-modp1536,aes256-sha384-modp2048,aes256-sha256-modp2048,aes256-sha1-modp2048,aes128-sha256-modp1024,aes128-sha1-modp1024,aes256-sha384-modp1536,aes256-sha256-modp1536,aes256-sha1-modp1536,aes256-sha384-modp1024,aes256-sha256-modp1024,aes256-sha1-modp1024!
  esp=aes128gcm16-ecp256,aes256gcm16-ecp384,aes128-sha256-ecp256,aes256-sha384-ecp384,aes128-sha256-modp2048,aes128-sha1-modp2048,aes256-sha384-modp4096,aes256-sha256-modp4096,aes256-sha1-modp4096,aes128-sha256-modp1536,aes128-sha1-modp1536,aes256-sha384-modp2048,aes256-sha256-modp2048,aes256-sha1-modp2048,aes128-sha256-modp1024,aes128-sha1-modp1024,aes256-sha384-modp1536,aes256-sha256-modp1536,aes256-sha1-modp1536,aes256-sha384-modp1024,aes256-sha256-modp1024,aes256-sha1-modp1024,aes128gcm16,aes256gcm16,aes128-sha256,aes128-sha1,aes256-sha384,aes256-sha256,aes256-sha1!
  
  # Server side
  # left - local (server) side
  # This is the IP address of the left end. %any means, for a responder, to use the IP address of the network interface through which the initiator is sending packets
  left=%any
  
  # This is the filename of the (public) X.509 certificate certifying the left peer's right to use the included Distinguished Name and/or hostname (SAN).
  leftcert=$SERVER_CERT
  
  # Routes pushed to clients. If you don't have ipv6 then remove ::/0
  # This is a comma separated list of CIDR address ranges which the client should be told to route through the tunnel.
  leftsubnet=0.0.0.0/0
  
  # right - remote (client) side
  # %any means that any host in the whole Internet can use this conn.
  right=%any
  rightid=%any

# conn inheritance :)
conn ike2-eap-radius
  also=ike2-eap-mschap2
  rightauth=eap-mschapv2
  eap_identity=peppelinux


# automatically load this configuration section when it starts up
conn ike2-eap-mschap2
  auto=add
  compress=no
  type=tunnel
  fragmentation=yes
  forceencaps=yes
  
  # which encryption algorithms to use for the VPN
  # ike=aes256-sha1-modp1024,3des-sha1-modp1024!
  # esp=aes256-sha1,3des-sha1!
  
  # leftid=@vpn12.unical.it
  leftid=@$CA_CN
  
  # There are choices for whan to send your certificate to the peer. Likely ifasked is sufficient, but I know that the client will always need the cert, so I avoid client screwups by always sending it.
  leftsendcert=always
    
  # automatically inserts iptables-based firewall rules that let pass the tunneled traffic
  leftfirewall=yes
  
  # Client side
  rightauth=eap-mschapv2
  
  # ipv4 and ipv6 subnets that assigns to clients. If you don't have ipv6 then remove it
  # rightsourceip=%dhcp # if dnsmasq is enabled
  rightsourceip=$VPN_NET
  
  rightdns=$VPN_DNS
  
  rightsendcert=never
  
  # ask the client for user credentials when they connect
  eap_identity=%identity
" > /etc/ipsec.conf

# configure vpn auth
echo "
# /etc/ipsec.secrets - strongSwan IPsec secrets file
# $CA_CN : RSA \"/etc/ipsec.d/private/vpn-server-key.pem\"
# include ipsec.*.secrets

: RSA vpn-server-key.pem

" > /etc/ipsec.secrets

# put any user you want appending them to secrets
echo "
mario : EAP \"rossi\"
monica : EAP \"camo\"
" >> /etc/ipsec.secrets

# on every secrets change reread them
ipsec rereadsecrets

# first run
# systemctl stop strongswan
# systemctl start strongswan

ipsec stop
ipsec start # Starting strongSwan 5.2.1 IPsec [starter]...
# ipsec reload # Reloading strongSwan IPsec configuration...

# status
ipsec status
ipsec statusall

# verify that all cerifitaces configured correctly by executing
ipsec listcerts

# list every enc and plugins
# ipsec listall

# diagnostics
# Setting xfrm. xfrm is an IP framework, which can transform format of the datagrams, i.e. encrypt the packets with some algorithm. xfrm policy and xfrm state are associated through templates TMPL_LIST. 
# This framework is used as a part of IPsec protocol.
# ip -s xfrm monitor
# ip -s xfrm policy
# ip -s xfrm state

# routing is quite transparent
# ip route show table all
# ip route list table 220

# introduction
# https://wiki.strongswan.org/projects/strongswan/wiki/IntroductiontostrongSwan
# http://jfcarter.net/~jimc/documents/strongswan-1308.html
# https://wiki.archlinux.org/index.php/StrongSwan

# official doc
# https://wiki.strongswan.org/projects/strongswan/wiki/IpsecCommand
# https://wiki.strongswan.org/projects/strongswan/wiki/Windows7#C-Authentication-using-EAP-MSCHAP-v2
# https://wiki.strongswan.org/projects/strongswan/wiki/IKEv2Examples
# https://www.strongswan.org/uml/testresults/ikev2/rw-eap-sim-id-radius/

# assign interface to tunnel (not only rt table 220 and xrfm)
# https://wiki.strongswan.org/projects/strongswan/wiki/RouteBasedVPN
# https://gist.github.com/heri16/2f59d22d1d5980796bfb
# https://wiki.strongswan.org/issues/2266
# https://end.re/2015-01-06_vti-tunnel-interface-with-strongswan.html

# connection trigger
# https://serverfault.com/questions/583907/running-a-custom-script-when-strongswan-connection-is-established

# tutorials
# https://hub.zhovner.com/geek/universal-ikev2-server-configuration/
# http://www.slsmk.com/strongswan-ipsec-vpn-for-remote-users-with-certificate-based-authentication/

# linux client gui network manager - client and server example
# https://wiki.strongswan.org/projects/strongswan/wiki/NetworkManager

# internals
# http://kernelspec.blogspot.it/2014/10/ipsec-implementation-in-linux-kernel.html
# https://blog.croz.net/en/blog/xfrm-programming/
# http://www.lorier.net/docs/xfrm

# end user
# http://help.uis.cam.ac.uk/devices-networks-printing/remote-access/uis-vpn/generic


