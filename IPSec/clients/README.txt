Su Linux è possibile che dipendenze o differenze di versioni tra server e client comportino 
problemi apparentemente di natura diversa... risolvibili con un allineamento
delle versioni, ovvero compilare.

Sul client
Scaricare i sorgenti della versione di strongswan da installare



SWVER="5.5.3"


aptitude install libldns-dev clearsilver-dev libfcgi-dev libsqlite3-dev

# debian 9: "No package 'libiptc' found"
# ./configure --enable-monolithic  --enable-acert --enable-bypass-lan --enable-cmd  --enable-connmark  --enable-eap-dynamic --enable-eap-identity --enable-eap-md5 --enable-eap-mschapv2  --enable-manager --enable-md4 --enable-md5 --enable-openssl  --enable-pkcs11  --enable-sha3 --enable-xauth-eap --prefix=/usr --sysconfdir=/etc

# mamanger da rogne con libxml
#./configure --enable-monolithic  --enable-acert --enable-bypass-lan --enable-cmd  --enable-eap-dynamic --enable-eap-identity --enable-eap-md5 --enable-eap-mschapv2  --enable-manager --enable-md4 --enable-md5 --enable-openssl  --enable-pkcs11  --enable-sha3 --enable-xauth-eap --prefix=/usr --sysconfdir=/etc

./configure --enable-monolithic  --enable-acert --enable-bypass-lan --enable-cmd  --enable-eap-dynamic --enable-eap-identity --enable-eap-md5 --enable-eap-mschapv2 --enable-md4 --enable-md5 --enable-openssl  --enable-pkcs11  --enable-sha3 --enable-xauth-eap --prefix=/usr --sysconfdir=/etc

cp -R /usr/include/libxml2/libxml .

make -j 4
make install

# if --prefix in ./configure was used...
# echo "/usr/local/lib/ipsec/plugins" > /etc/ld.so.conf.d/strongswan$SWVER.conf

