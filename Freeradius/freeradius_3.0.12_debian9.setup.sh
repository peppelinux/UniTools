
export RADCONFD="/etc/freeradius/3.0/"
# CHANGE IT !
export RADIUS_PWD="radiussecret"

aptitude install freeradius-mysql mysql-server
service freeradius stop

cd $RADCONFD
cd certs

export SSL_countryName="IT"
export SSL_stateOrProvinceName="Cosenza"
export SSL_organizationName="DIATIC"
export SSL_emailAddress="giuseppe.demarco@unical.it"
export SSL_commonName="eduroam-DIATIC"
export SSL_subjectAltName="Diatic"
export SSL_localityName="Arcavacata"
export SSL_default_days="3650"

# these sed breaks policy_match rules
# then you should replace them fromyour /etc/ssl/openssl.cnf
# TODO, do a python YAML script to make changes without hardcoded regexp!!!

#[ policy_match ]
#countryName		= match
#stateOrProvinceName	= match
#organizationName	= match
#organizationalUnitName	= optional
#commonName		= supplied
#emailAddress		= optional

# server.cnf
sed -i 's/countryName\t*\s*= .*/countryName = "'"$SSL_countryName"'"/' server.cnf
sed -i 's/stateOrProvinceName\t*\s*= .*/stateOrProvinceName = "'"$SSL_stateOrProvinceName"'"/' server.cnf
sed -i 's/organizationName\t*\s*= .*/organizationName = "'"$SSL_organizationName"'"/' server.cnf
sed -i 's/emailAddress\t*\s*= .*/emailAddress = "'"$SSL_emailAddress"'"/' server.cnf
sed -i 's/commonName\t*\s*= .*/commonName = "'"$SSL_commonName"'"/' server.cnf
sed -i 's/subjectAltName\t*\s*= .*/subjectAltName = "'"$SSL_subjectAltName"'"/' server.cnf
sed -i 's/localityName\t*\s*= .*/localityName = "'"$SSL_localityName"'"/' server.cnf
sed -i 's/default_days\t*\s*= .*/default_days = "'"$SSL_default_days"'"/' server.cnf

# ca.cnf
sed -i 's/countryName\t*\s*=.*/countryName = "'"$SSL_countryName"'"/' ca.cnf
sed -i 's/stateOrProvinceName\t*\s*= .*/stateOrProvinceName = "'"$SSL_stateOrProvinceName"'"/' ca.cnf
sed -i 's/organizationName\t*\s*= .*/organizationName = "'"$SSL_organizationName"'"/' ca.cnf
sed -i 's/emailAddress\t*\s*= .*/emailAddress = "'"$SSL_emailAddress"'"/' ca.cnf
sed -i 's/commonName\t*\s*= .*/commonName = "'"$SSL_commonName"'"/' ca.cnf
sed -i 's/subjectAltName\t*\s*= .*/subjectAltName = "'"$SSL_subjectAltName"'"/' ca.cnf
sed -i 's/localityName\t*\s*= .*/localityName = "'"$SSL_localityName"'"/' ca.cnf
sed -i 's/default_days\t*\s*= .*/default_days = "'"$SSL_default_days"'"/' ca.cnf
# client.cnf
sed -i 's/countryName\t*\s*=.*/countryName = "'"$SSL_countryName"'"/' client.cnf
sed -i 's/stateOrProvinceName\t*\s*=.*/stateOrProvinceName = "'"$SSL_stateOrProvinceName"'"/' client.cnf
sed -i 's/organizationName\t*\s*=.*/organizationName = "'"$SSL_organizationName"'"/' client.cnf
sed -i 's/emailAddress\t*\s*=.*/emailAddress = "'"$SSL_emailAddress"'"/' client.cnf
sed -i 's/commonName\t*\s*=.*/commonName = "'"$SSL_commonName"'-client"/' client.cnf
sed -i 's/subjectAltName\t*\s*=.*/subjectAltName = "'"$SSL_subjectAltName"'"/' client.cnf
sed -i 's/localityName\t*\s*= .*/localityName = "'"$SSL_localityName"'"/' client.cnf
sed -i 's/default_days\t*\s*= .*/default_days = "'"$SSL_default_days"'"/' client.cnf

# modify crlDistributionPoints  with a real one
# this also must be edited in ca.cnf
nano xpextensions
# check all the configuration, change input_password and input_password in client.cnf and server.cnf
nano ca.cnf server.cnf client.cnf

# pulizia
rm -f *.pem *.der *.csr *.crt *.key *.p12 serial* index.txt*

# This step creates the CA certificate.
make ca.pem

# This step creates the DER format of the self-signed certificate, which is can be imported into Windows.
make ca.der

#echo "unique_subject = yes" > index.txt.attr
make server.pem
make server.csr
make client.pem

# check
 openssl x509 -in ca.pem -text -noout

cd $RADCONFD
echo "restore mysql schema from"
find . -type f | grep schema.sql  | grep mysql | grep main | grep -v extras

# configure mysql
mysql -u root -p -e \
"CREATE DATABASE IF NOT EXISTS radius; GRANT ALL ON radius.* TO radius@localhost IDENTIFIED BY '$RADIUS_PWD'; \
flush privileges;"

mysql -u radius --password=$RADIUS_PWD radius < $RADCONFD./mods-config/sql/main/mysql/schema.sql

# configure mysql db connection
sed -i 's/.*driver = "rlm_sql_null"/driver = "rlm_sql_mysql"/' $RADCONFD/mods-available/sql
sed -i 's/dialect = "sqlite"/dialect = "mysql"/' $RADCONFD/mods-available/sql
sed -i 's/#.*server = "localhost"/       server = "localhost"/' $RADCONFD/mods-available/sql
sed -i 's/#.*port = 3306/       port = 3306/' $RADCONFD/mods-available/sql
sed -i 's/#.*login = "radius"/        login = "radius"/' $RADCONFD/mods-available/sql
sed -i 's/#.*password = "radpass"/        password = "'$RADIUS_PWD'"/' $RADCONFD/mods-available/sql

# sqlcounter patch
sed -i 's|dialect = ${modules.sql.dialect}|dialect = mysql|g' $RADCONFD/mods-available/sqlcounter

# enable mysql module
ln -s $RADCONFD/mods-available/sql        $RADCONFD/mods-enabled/
ln -s $RADCONFD/mods-available/sqlcounter $RADCONFD/mods-enabled/

# auth

# auth
# inner-tunnel
#sed -i 's|-sql|sql|' $RADCONFD/sites-enabled/inner-tunnel # authorize section
sed -i 's|session {|session {\nsql|' $RADCONFD/sites-enabled/inner-tunnel
# default
#sed -i 's|-sql|sql|' $RADCONFD/sites-enabled/default # authorize section
sed -i 's|session {|session {\nsql|' $RADCONFD/sites-enabled/default
sed -i 's|accounting {|accounting {\nsql|' $RADCONFD/sites-enabled/default

# disable unused eap methods
sed -i 's|default_eap_type = md5|default_eap_type = peap|' $RADCONFD/mods-available/eap
# also enable in PEAP and TTLS for Eduroam IDP compliance, these are:
#copy_request_to_tunnel = yes
#use_tunneled_reply = yes

# rememebr to disable md5 auth in eap module
        #
        #  We do NOT recommend using EAP-MD5 authentication
        #  for wireless connections.  It is insecure, and does
        #  not provide for dynamic WEP keys.
        #
        #md5 {
        #}

# remember also to disable GTC e LEAP, these are very insecure!

# logging
# it could be done also with this:
# radiusconfig -setconfig auth yes
# radiusconfig -setconfig auth_badpass yes
#sed -i 's|logdir = ${localstatedir}/log/radius|logdir = /var/log/radius|' $RADCONFD/radiusd.conf
#sed -i 's|auth_badpass = no|auth_badpass = yes|g' $RADCONFD/radiusd.conf
#sed -i 's|auth_goodpass = no|auth_goodpass = yes|g' $RADCONFD/radiusd.conf
sed -i 's|auth = no|auth = yes|g' $RADCONFD/radiusd.conf

# accounting logs, readable in $logdir/acct/*
sed -i 's|#.*auth_log|auth_log|' $RADCONFD/sites-enabled/default
sed -i 's|#\s*reply_log$|reply_log|' $RADCONFD/sites-enabled/default

# radlast command workaround (.f option doesn't still work)
mkdir -p /usr/local/var/log/radius/
ln -s /var/log/freeradius/radwtmp /usr/local/var/log/radius/

update-rc.d  freeradius enable 2

# create user in radcheck table

# test user with a Cleartext-Password
# radtest {username} {password} {hostname} 0 {radius_secret}

# use ALWAYS MSCHAP and not cleartext incapsulated in PAP (as default behaviour)!
# radtest -t mschap test@test.realm.it test localhost 0 testing123

# with eap
# you have to compile eapol_test first :)
# wget latest wpa-supplicant and decompress it
# aptitude install libnl-3-dev libssl-dev
# check if lib path is good, else: ln -s /lib/x86_64-linux-gnu/libnl-3.so /lib/x86_64-linux-gnu/libnl.so
# cp defconfig .config && nano .config # change CONFIG_EAPOL_TEST=y
# make eapol_test && cp eapol_test /usr/local/bin
echo "
#
#   eapol_test -c peap-mschapv2.conf -s testing123
#
network={
        ssid="example"
        key_mgmt=WPA-EAP
        eap=PEAP
        identity="testuser@test.unical.it"
        #anonymous_identity="anonymous"
        password="that_password"
        phase2="autheap=MSCHAPV2"

        #
        #  Uncomment the following to perform server certificate validation.
#       ca_cert="/etc/raddb/certs/ca.der"
}" > eapol_peap
# eapol_test -s testing123 -c eapol_peap
# eapol_test -a 10.87.7.213  -s SeCreTXXx -c eapol_test 
