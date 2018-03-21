aptitude install openvpn easy-rsa
cd /etc/openvpn/

# consiglio di modificare make_ca.sh e automatizzare la creazione dei certificati con questo
bash make_ca.sh

# altrimenti
# se debian inferiore a stretch 9.0
# cp -R /usr/share/doc/openvpn/examples/easy-rsa/2.0/* easy-rsa/
cp -R /usr/share/easy-rsa/ easy-rsa/
cd easy-rsa

# edito le variabili per customizzare i certificati
nano vars
mkdir keys
touch keys/index.txt

# faccio un source per operare in questo ambiente
. ./vars

ln -s openssl-1.0.0.cnf openssl.cnf

# pulisco cacche esemplificative
./clean-all

./build-ca
./build-key-server server
./build-dh

# dopodichè creiamo i nostri clients
./build-key username-preferito

# o equivalente:
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/99-sysctl.conf

echo AUTOSTART="server" >> /etc/default/openvpn 

systemctl enable openvpn
