Su Linux è possibile che dipendenze o differenze di versioni tra server e client comportino 
problemi apparentemente di natura diversa... risolvibili con un allineamento
delle versioni, ovvero compilare.

Diffidare dei pacchetti Debian9, i plugin sono incompleti.

Sul client
Scaricare i sorgenti della versione di strongswan da installare

SWVER="5.6.0"

aptitude install libldns-dev clearsilver-dev libfcgi-dev libsqlite3-dev libgmp-dev libldap-dev libcurl4-openssl-dev libgcrypt20-dev libpam-dev pkg-config libiptc-dev

# ubnt 16.04
# aptitude install libldns-dev clearsilver-dev libfcgi-dev libsqlite3-dev libgmp-dev libldap-dev libcurl4-openssl-dev libgcrypt20-dev libpam-dev pkg-config libmysqlclient-dev iptables-dev 


# debian 9: "No package 'libiptc' found" riguarda iptables-dev e non iptcdata!
# --enable-manager # da testare

./configure --enable-test-vectors --enable-ldap --enable-pkcs11 --enable-aesni --enable-aes --enable-rc2 --enable-sha2 --enable-sha1 --enable-md5 --enable-rdrand --enable-random --enable-nonce --enable-x509 --enable-revocation --enable-constraints --enable-pubkey --enable-pkcs1 --enable-pkcs7 --enable-pkcs8 --enable-pkcs12 --enable-pgp --enable-dnskey --enable-sshkey --enable-pem --enable-openssl --enable-gcrypt --enable-af-alg --enable-fips-prf --enable-gmp --enable-agent --enable-xcbc --enable-cmac --enable-hmac --enable-ctr --enable-ccm --enable-gcm --enable-curl --enable-attr --enable-kernel-netlink --enable-resolve --enable-socket-default --enable-connmark --enable-farp --enable-stroke --enable-vici --enable-updown --enable-eap-identity --enable-eap-aka --enable-eap-md5 --enable-eap-gtc --enable-eap-mschapv2 --enable-eap-radius --enable-eap-tls --enable-eap-ttls --enable-eap-tnc --enable-xauth-generic --enable-xauth-eap --enable-xauth-pam --enable-tnc-tnccs --enable-dhcp --enable-lookip --enable-error-notify --enable-certexpire --enable-led --enable-addrblock --enable-unity --enable-monolithic \
--enable-blowfish \
-enable-af-alg \
--enable-acert \
--enable-bypass-lan \
--enable-cmd \
--enable-eap-dynamic \
--enable-md4 \
--enable-sha3 \
--enable-eap-aka-3gpp2 \
--enable-blowfish \
--enable-af-alg \
--enable-attr-sql \
--enable-mysql \
--prefix=/usr/local --sysconfdir=/usr/local/etc

cp -R /usr/include/libxml2/libxml .

make -j 4
make install

# if --prefix in ./configure was used...
echo "/usr/lib/ipsec" > /etc/ld.so.conf.d/strongswan_$SWVER.conf

