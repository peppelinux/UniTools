Debian 9
--------

````
sudo apt install libldns-dev clearsilver-dev libfcgi-dev libsqlite3-dev libgmp-dev libldap-dev libcurl4-openssl-dev libgcrypt20-dev libpam-dev pkg-config libiptc-dev libmysqlclient-dev  iptables-dev
libunbound-dev libsoup*-dev libsystemd-dev libtspi-dev libjson-c-dev libpcsclite-dev libnm-dev binutils-dev libunwind-dev gpr-build lcov libwinpr-winsock0.1
````

this configuration gets an error of undefined symbols. Need to be tested on Debian10!
````
./configure --prefix=/usr --sysconfdir=/etc --enable-all --disable-tss-trousers --disable-tss-tss2 --disable-botan --disable-uci --disable-android-dns --disable-ruby-gems --disable-ruby-gems-install --disable-winhttp --disable-padlock --disable-keychain --disable-dbghelp-backtraces
````

old style that works
````
./configure --enable-test-vectors \
--enable-ldap \
--enable-aesni \
--enable-aes \
--enable-rc2 \
--enable-sha2 \
--enable-sha1 \
--enable-md5 \
--enable-rdrand \
--enable-random \
--enable-nonce \
--enable-x509 \
--enable-revocation \
--enable-constraints \
--enable-pubkey \
--enable-pkcs1 \
--enable-pkcs7 \
--enable-pkcs8 \
--enable-pkcs11 \
--enable-pkcs12 \
--enable-pgp \
--enable-dnskey \
--enable-sshkey \
--enable-pem \
--enable-openssl \
--enable-gcrypt \
--enable-af-alg \
--enable-fips-prf \
--enable-gmp \
--enable-agent \
--enable-xcbc \
--enable-cmac \
--enable-hmac \
--enable-ctr \
--enable-ccm \
--enable-gcm \
--enable-curl \
--enable-attr \
--enable-kernel-netlink \
--enable-resolve \
--enable-socket-default \
--enable-connmark \
--enable-farp \
--enable-stroke \
--enable-vici \
--enable-updown \
--enable-eap-identity \
--enable-eap-aka \
--enable-eap-md5 \
--enable-eap-gtc \
--enable-eap-mschapv2 \
--enable-eap-radius \
--enable-eap-tls \
--enable-eap-ttls \
--enable-eap-tnc \
--enable-xauth-generic \
--enable-xauth-eap \
--enable-xauth-pam \
--enable-dhcp \
--enable-lookip \
--enable-error-notify \
--enable-certexpire \
--enable-led \
--enable-addrblock \
--enable-unity \
--enable-monolithic \
--enable-blowfish \
--enable-acert \
--enable-bypass-lan \
--enable-cmd \
--enable-eap-dynamic \
--enable-md4 \
--enable-sha3 \
--enable-eap-aka-3gpp2 \
--enable-blowfish \
--enable-attr-sql \
--enable-mysql \
--prefix=/usr --sysconfdir=/etc
````
