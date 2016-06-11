#!/bin/bash

set -x

aptitude install openvpn
cd /etc/openvpn/
cp -R /usr/share/doc/openvpn/examples/easy-rsa/2.0/* easy-rsa/

cd easy-rsa

# edito le variabili per customizzare i certificati
nano vars
touch keys/index.txt

# faccio un source per operare in questo ambiente
. ./vars

# pulisco cacche esemplificative
./clean-all

./build-ca
./build-key-server server
./build-dh
./build-key username-preferito
