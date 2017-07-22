 # ___ ____  ____  _____ ____ 
# |_ _|  _ \/ ___|| ____/ ___|
 # | || |_) \___ \|  _|| |    
 # | ||  __/ ___) | |__| |___ 
# |___|_|   |____/|_____\____|

set -e
set -x

CA_BASEDIR="/opt"
CA_DIRNAME="CA-ipsec"
CA_PATH=$CA_BASEDIR/$CA_DIRNAME
RSA_BIT=4096
CERT_LIFETIME=3650
# ip or hostname of the server
CA_CN="vpn12.unical.it"
CA_DN="C=IT, O=UNICAL, CN=$CA_CN"
VPN_NET="10.9.8.0/24"
VPN_DNS="10.9.8.1"

# apt-get purge *strongswan*
# apt-get purge *charon*

apt-get install aptitude
aptitude install strongswan moreutils iptables-persistent

# ubuntu 16
# aptitude install strongswan-plugin-eap-mschapv2

# debian 9
# aptitude install strongswan-pki libcharon-extra-plugins strongswan-ikev2 strongswan-swanctl 

# CA, an IKEv2 server requires a certificate to identify itself to clients.
if [ -d "$CA_PATH" ]; then
    mv $CA_PATH $CA_PATH.$(date +"%Y-%m-%d.%H:%M")
fi
mkdir $CA_PATH && cd $CA_PATH

ipsec pki --gen --type rsa --size $RSA_BIT --outform pem > $CA_PATH/server-root-key.pem
chmod 600 $CA_PATH/server-root-key.pem

# You can change the distinguished name (DN) values, such as country, 
# organization, and common name, to something else to if you want to.
ipsec pki --self --ca --lifetime $CERT_LIFETIME \
--in $CA_PATH/server-root-key.pem \
--type rsa --dn "$CA_DN" \
--outform pem > $CA_PATH/server-root-ca.pem
# Later, we'll copy the root certificate (server-root-ca.pem) to our client devices so they can verify the authenticity of the server when they connect

ipsec pki --gen --type rsa --size $RSA_BIT --outform pem > $CA_PATH/vpn-server-key.pem

ipsec pki --pub --in $CA_PATH/vpn-server-key.pem \
--type rsa | ipsec pki --issue --lifetime $CERT_LIFETIME \
--cacert $CA_PATH/server-root-ca.pem \
--cakey $CA_PATH/server-root-key.pem \
--dn "$CA_DN" \
--san $CA_CN \
--flag serverAuth --flag ikeIntermediate \
--outform pem > $CA_PATH/vpn-server-cert.pem

# ipsec setup
cp $CA_PATH/vpn-server-cert.pem /etc/ipsec.d/certs/
cp $CA_PATH/vpn-server-key.pem /etc/ipsec.d/private/

chown root /etc/ipsec.d/private/*
chgrp root /etc/ipsec.d/private/*
chmod -R 600 /etc/ipsec.d/private/

# Strongswan setup
# backupit first
mv /etc/ipsec.conf /etc/ipsec.conf.$(date +"%Y-%m-%d.%H:%M")

# strongswan setup
echo "
config setup
  #charondebug=\"cfg 2, dmn 2, ike 2, net 2, lib 2\"
  charondebug=\"ike 1, knl 1, cfg 0\"
  uniqueids=no
  # charondebug=\"all\"
  # uniqueids=yes
  # strictcrlpolicy=no
        
# automatically load this configuration section when it starts up
conn ikev2-vpn
  auto=add
  compress=no
  type=tunnel
  keyexchange=ikev2
  fragmentation=yes
  forceencaps=yes
  
  # which encryption algorithms to use for the VPN
  ike=aes256-sha1-modp1024,3des-sha1-modp1024!
  esp=aes256-sha1,3des-sha1!
  
  # dead-peer detection to clear any \"dangling\" connections in case the client unexpectedly disconnects
  dpdaction=clear
  dpddelay=300s
  rekey=no

  # left - local (server) side
  left=%any
  # leftid=@vpn.unical.it
  leftid=@$CA_CN
  leftcert=/etc/ipsec.d/certs/vpn-server-cert.pem
  leftsendcert=always
  
  # Routes pushed to clients. If you don't have ipv6 then remove ::/0
  leftsubnet=0.0.0.0/0
  
  # right - remote (client) side
  right=%any
  rightid=%any
  rightauth=eap-mschapv2
  
  # ipv4 and ipv6 subnets that assigns to clients. If you don't have ipv6 then remove it
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

# put any user you want appending it to secrets
echo "
#mario %any% : EAP \"rossi\"
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

# erify that all cerifitaces configured correctly by executing
ipsec listall

# https://wiki.strongswan.org/projects/strongswan/wiki/IKEv2Examples
# https://www.strongswan.org/uml/testresults/ikev2/rw-eap-sim-id-radius/
# https://hub.zhovner.com/geek/universal-ikev2-server-configuration/
# http://www.slsmk.com/strongswan-ipsec-vpn-for-remote-users-with-certificate-based-authentication/
