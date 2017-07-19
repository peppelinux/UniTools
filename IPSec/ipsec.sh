 # ___ ____  ____  _____ ____ 
# |_ _|  _ \/ ___|| ____/ ___|
 # | || |_) \___ \|  _|| |    
 # | ||  __/ ___) | |__| |___ 
# |___|_|   |____/|_____\____|

CA_BASEDIR="/opt"
CA_DIRNAME="CA-ipsec"
CA_PATH=$CA_BASEDIR$CA_DIRNAME
RSA_BIT=4096
CERT_LIFETIME=3650
# ip or hostname of the server
CA_CN="vpn1.unical.it"
CA_DN="C=IT, O=UNICAL, CN=$CA_CN"
VPN_NET="10.160.97.0/24"
VPN_DNS="160.97.7.13,160.97.7.14"

apt-get install aptitude
aptitude install strongswan moreutils iptables-persistent

# ubuntu 16
aptitude install strongswan-plugin-eap-mschapv2

# debian 9, già nelle dipendenze di strongswan
# aptitude install libstrongswan-standard-plugins 

# CA, an IKEv2 server requires a certificate to identify itself to clients.
mv $CA_PATH $CA_PATH.$(date +"%Y-%m-%d.%H:%M")
mkdir $CA_PATH && cd $CA_PATH

ipsec pki --gen --type rsa --size $RSA_BIT --outform pem > server-root-key.pem
chmod 600 server-root-key.pem

# You can change the distinguished name (DN) values, such as country, 
# organization, and common name, to something else to if you want to.
ipsec pki --self --ca --lifetime $CERT_LIFETIME \
--in server-root-key.pem \
--type rsa --dn $CA_DN \
--outform pem > server-root-ca.pem

ipsec pki --gen --type rsa --size $RSA_BIT --outform pem > vpn-server-key.pem

ipsec pki --pub --in vpn-server-key.pem \
--type rsa | ipsec pki --issue --lifetime $CERT_LIFETIME \
--cacert server-root-ca.pem \
--cakey server-root-key.pem \
--dn $CA_DN \
--san $CA_CN \
--flag serverAuth --flag ikeIntermediate \
--outform pem > vpn-server-cert.pem

# ipsec setup
cp $CA_PATH/vpn-server-cert.pem /etc/ipsec.d/certs/
cp $CA_PATH/vpn-server-key.pem /etc/ipsec.d/private/

chown root
chgrp root
chmod -R 600 /etc/ipsec.d/private/

# Strongswan setup
# backupit first
mv /etc/ipsec.conf /etc/ipsec.conf.$(date +"%Y-%m-%d.%H:%M")

# strongswan setup
echo "
config setup
  charondebug=\"ike 1, knl 1, cfg 0\"
  uniqueids=no

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

  left=%any
  # leftid=@vpn.unical.it
  leftid=@$CA_CN
  leftcert=/etc/ipsec.d/certs/vpn-server-cert.pem
  leftsendcert=always
  leftsubnet=0.0.0.0/0

  right=%any
  rightid=%any
  rightauth=eap-mschapv2
  rightsourceip=$VPN_NET
  rightdns=$VPN_DNS
  rightsendcert=never
  
  # ask the client for user credentials when they connect
  eap_identity=%identity
  

" > /etc/ipsec.conf

# configure vpn auth
echo "
$CA_CN : RSA \"/etc/ipsec.d/private/vpn-server-key.pem\"
" > /etc/ipsec.secrets

# put any user you want appending it to secrets
echo "
mario %any% : EAP \"rossi\"
monica %any% : EAP \"camo\"
" >> /etc/ipsec.secrets

# first run
ipsec start # Starting strongSwan 5.2.1 IPsec [starter]...
ipsec reload # Reloading strongSwan IPsec configuration...





