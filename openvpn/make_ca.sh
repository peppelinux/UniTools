#!/bin/bash
export PEM_PATH="keys/pem"
export CERT_PATH=`pwd`"/roles/common/files/certs"
export SERVER_FQDN="your.dyndns.ip"

apt install easy-rsa -y
rm -f easy-rsa
cp -Rp /usr/share/easy-rsa/ .

cd /etc/openvpn
cd easy-rsa

# link easy-rsa ssl config defaults
# You can also edit it to change some informations about issuer and remove EASY-Rsa messages
ln -s openssl-1.0.0.cnf openssl.cnf # won't works with CommonName

# using original openssl file (needs more customizations)
# cp /etc/ssl/openssl.cnf openssl.cnf
# sed -i '1s/^/# For use with easy-rsa version 2.0 and OpenSSL 1.0.0*\n/' openssl.cnf

# customize informations in vars file (or override them later with env VAR)
# remember to configure "Common Name (your server's hostname)" in your certs 
# to let your client avoids "does not match common name in certificate"
# nano vars

# then source it
. ./vars

# override for speedup
export KEY_ALTNAMES=$SERVER_FQDN
export KEY_OU=$SERVER_FQDN
export KEY_NAME=$SERVER_FQDN

export KEY_COUNTRY="IT"
export KEY_PROVINCE="CS"
export KEY_CITY="Cosenza"
export KEY_ORG=$SERVER_FQDN
export KEY_EMAIL="me@$SERVER_FQDN"

./clean-all

./build-ca
./build-dh
./build-key $SERVER_FQDN

mkdir -p $PEM_PATH

openssl x509 -inform PEM -in keys/ca.crt > $PEM_PATH/$KEY_ORG-cacert.pem

# SERVER_FQDN certs
openssl x509 -inform PEM -in keys/$SERVER_FQDN.crt > $PEM_PATH/$SERVER_FQDN-cert.pem
openssl rsa -in keys/$SERVER_FQDN.key -text > $PEM_PATH/$SERVER_FQDN-key.pem

mkdir -p $CERT_PATH
cp $PEM_PATH/$KEY_ORG-cacert.pem $CERT_PATH/
cp $PEM_PATH/$SERVER_FQDN-*.pem $CERT_PATH/
