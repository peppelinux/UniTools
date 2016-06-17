#!/bin/bash

export RAD_VER="v3.0.x"
export INST_PREFIX="/usr/local"
export RAD_CONF=$INST_PREFIX"/etc/raddb"
export RAD_SRC_PRE=$HOME"/Progs"
export RAD_SRC=$RAD_SRC_PRE"/freeradius-server_$RAD_VER"

# CHANGE IT !
export RADIUS_PWD="radius_pwd"

set -x

# get dependencies
aptitude update
aptitude install libtalloc-dev libtalloc2 libcollectdclient-dev libcollectdclient1 libpcap-dev libpcap0.8 snmp libcap2-dev libcap-dev libmemcached-dev libyubikey-dev libyubikey0 libunbound2 libunbound-dev libmysqlclient-dev libmysqlclient18 ruby libcurlpp-dev libcurlpp0  libpython-dev python-dev libperl-dev libidn2-0 libidn2-0-dev libjson0-dev libwbclient-dev libwbclient0 libldap-dev libldap2-dev libpam-dev libkrb5-dev libcurl4-openssl-dev samba-dev libhiredis-dev  libssl-dev libgdbm-dev build-essential

# get freeradius sources
git clone -b $RAD_VER https://github.com/FreeRADIUS/freeradius-server.git
mkdir -p $RAD_SRC_PRE
mv freeradius-server $RAD_SRC

cd $RAD_SRC

./configure --prefix=$INST_PREFIX --without-experimental-modules --disable-developer #  | grep WARNING
make -j 4

# Change cert attributes as you prefer before install it
export SSL_countryName="IT"
export SSL_stateOrProvinceName="Cosenza"
export SSL_organizationName="OrgName"
export SSL_emailAddress="some@where.eu"
export SSL_commonName="OrgName"
export SSL_subjectAltName="AltOrgName"

# server.cnf
sed -i 's/countryName             = FR/countryName = $SSL_countryName/' $RAD_SRC/raddb/certs/server.cnf
sed -i 's/stateOrProvinceName     = Radius/stateOrProvinceName = $SSL_stateOrProvinceName/' $RAD_SRC/raddb/certs/server.cnf
sed -i 's/organizationName        = Example Inc/organizationName = $SSL_organizationName/' $RAD_SRC/raddb/certs/server.cnf
sed -i 's/emailAddress            = admin@example.org/emailAddress = $SSL_emailAddress/' $RAD_SRC/raddb/certs/server.cnf
sed -i 's/commonName              = "Example Server Certificate"/commonName = $SSL_commonName/' $RAD_SRC/raddb/certs/server.cnf
sed -i 's/subjectAltName          = radius.example.org/subjectAltName = $SSL_subjectAltName/' $RAD_SRC/raddb/certs/server.cnf
# ca.cnf
sed -i 's/countryName             = FR/countryName = $SSL_countryName/' $RAD_SRC/raddb/certs/server.cnf
sed -i 's/stateOrProvinceName     = Radius/stateOrProvinceName = $SSL_stateOrProvinceName/' $RAD_SRC/raddb/certs/ca.cnf
sed -i 's/organizationName        = Example Inc/organizationName = $SSL_organizationName/' $RAD_SRC/raddb/certs/ca.cnf
sed -i 's/emailAddress            = admin@example.org/emailAddress = $SSL_emailAddress/' $RAD_SRC/raddb/certs/ca.cnf
sed -i 's/commonName              = "Example Server Certificate"/commonName = $SSL_commonName/' $RAD_SRC/raddb/certs/ca.cnf
sed -i 's/subjectAltName          = radius.example.org/subjectAltName = $SSL_subjectAltName/' $RAD_SRC/raddb/certs/ca.cnf
# client.cnf
sed -i 's/countryName             = FR/countryName = $SSL_countryName/' $RAD_SRC/raddb/certs/client.cnf
sed -i 's/stateOrProvinceName     = Radius/stateOrProvinceName = $SSL_stateOrProvinceName/' $RAD_SRC/raddb/certs/client.cnf
sed -i 's/organizationName        = Example Inc/organizationName = $SSL_organizationName/' $RAD_SRC/raddb/certs/client.cnf
sed -i 's/emailAddress            = admin@example.org/emailAddress = $SSL_emailAddress/' $RAD_SRC/raddb/certs/client.cnf
sed -i 's/commonName              = "Example Server Certificate"/commonName = $SSL_commonName/' $RAD_SRC/raddb/certs/client.cnf
sed -i 's/subjectAltName          = radius.example.org/subjectAltName = $SSL_subjectAltName/' $RAD_SRC/raddb/certs/client.cnf

# create optional startup options
echo 'FREERADIUS_OPTIONS=""' > /etc/default/freeradius

# customize systemd.service 
sed -i 's|ExecStartPre=/usr/sbin/freeradius $FREERADIUS_OPTIONS -Cx -lstdout|ExecStartPre=$INST_PREFIX/sbin/radiusd $FREERADIUS_OPTIONS -Cx -lstdout|' $RAD_SRC/debian/freeradius.service 
sed -i 's|ExecStartPre=/usr/sbin/freeradius $FREERADIUS_OPTIONS -Cx -lstdout|ExecStart=$INST_PREFIX/sbin/radiusd $FREERADIUS_OPTIONS|' $RAD_SRC/debian/freeradius.service 
sed -i 's|After=syslog.target network.target|After=syslog.target network.target mysql.service|' $RAD_SRC/debian/freeradius.service 

# install freeradius in standard path (/usr/local/)
make install

# configure daemon
export R1=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
export R2=$(date +%s | sha256sum | base64 | head -c 32 ; echo)

export RAD_SECRET="$R1$R2"
echo "Generating secret...."
echo $RAD_SECRET

# permissions
useradd radius
groupadd radius
mkdir /var/log/radius
chown -R radius /var/log/radius
chgrp -R radius /var/log/radius
chown -R radius $RAD_CONF
chgrp -R radius $INST_PREFIX/var/run/radiusd
chmod -R g+w $INST_PREFIX/var/run/radiusd
sed -i  -e 's|^.*user = radius|       user = radius|g' $RAD_CONF/radiusd.conf
sed -i  -e 's|^.*group = radius|       group = radius|g' $RAD_CONF/radiusd.conf



# configure mysql db connection
sed -i 's/.*driver = "rlm_sql_null"/driver = "rlm_sql_mysql"/' $RAD_CONF/mods-available/sql
sed -i 's/dialect = "sqlite"/dialect = "mysql"/' $RAD_CONF/mods-available/sql
sed -i 's/#.*server = "localhost"/       server = "localhost"/' $RAD_CONF/mods-available/sql
sed -i 's/#.*port = 3306/       port = 3306/' $RAD_CONF/mods-available/sql
sed -i 's/#.*login = "radius"/        login = "radius"/' $RAD_CONF/mods-available/sql
sed -i 's/#.*password = "radpass"/        password = "'$RADIUS_PWD'"/' $RAD_CONF/mods-available/sql

# enable sql
pushd $RAD_CONF
ln -s $RAD_CONF/mods-available/sql        $RAD_CONF/mods-enabled/
#ln -s $RAD_CONF/mods-available/sql_mysql  $RAD_CONF/mods-enabled/ # funziona senza
ln -s $RAD_CONF/mods-available/sqlcounter $RAD_CONF/mods-enabled/
popd

# read client from database instead of clients.conf
#sed -i 's|#.*read_clients = yes|read_clients = yes|g' $RAD_CONF/mods-available/sql

# sqlcounter patch
sed -i 's|dialect = ${modules.sql.dialect}|dialect = mysql|g' $RAD_CONF/mods-available/sqlcounter

# auth
# inner-tunnel
sed -i 's|-sql|sql|' $RAD_CONF/sites-enabled/inner-tunnel # authorize section
sed -i 's|session {|session {\nsql|' $RAD_CONF/sites-enabled/inner-tunnel
# default
sed -i 's|-sql|sql|' $RAD_CONF/sites-enabled/default # authorize section
sed -i 's|session {|session {\nsql|' $RAD_CONF/sites-enabled/default
sed -i 's|accounting {|accounting {\nsql|' $RAD_CONF/sites-enabled/default

# disable unused eap methods
sed -i 's|default_eap_type = md5|default_eap_type = peap|' $RAD_CONF/mods-available/eap


# logging
# it could be done also with this:
# radiusconfig -setconfig auth yes
# radiusconfig -setconfig auth_badpass yes
sed -i 's|logdir = ${localstatedir}/log/radius|logdir = /var/log/radius|' $RAD_CONF/radiusd.conf
sed -i 's|auth_badpass = no|auth_badpass = yes|g' $RAD_CONF/radiusd.conf
sed -i 's|auth_goodpass = no|auth_goodpass = yes|g' $RAD_CONF/radiusd.conf
sed -i 's|auth = no|auth = yes|g' $RAD_CONF/radiusd.conf

# accounting logs, readable in $logdir/acct/*
sed -i 's|#.*auth_log|auth_log|' $RAD_CONF/sites-enabled/default
sed -i 's|#.*reply_log|reply_log|' $RAD_CONF/sites-enabled/default


# configure mysql
mysql -u root -p -e \
"CREATE DATABASE IF NOT EXISTS radius; GRANT ALL ON radius.* TO radius@localhost IDENTIFIED BY '$RADIUS_PWD'; \
flush privileges;"

mysql -u radius --password=$RADIUS_PWD radius  < $RAD_SRC/mods-config/sql/main/mysql/schema.sql

# cp freeradius.service in systemd services folder
cp $RAD_SRC/debian/freeradius.service  /lib/systemd/system/


# reload and restart 
systemctl daemon-reload 
systemctl enable freeradius
systemctl start freeradius


# 
# notes ==================

# proxy.conf - place where realms are
#realm NULL {
        #authhost        = 10.97.67.4:1812
##       accthost        = radius.company.com:1601
        #secret          = l390q478yhsg456
#}

#realm dominio.it {

#}

#
# ========================

# hashing NTLM password in python (instead of "smbencrypt password")
# import hashlib,binascii
# hash = hashlib.new('md4', "password".encode('utf-16le')).digest()
# print binascii.hexlify(hash)

# custom certs
# https://www.ossramblings.com/RADIUS-3.X-Server-on-Ubuntu-14.04-for-WIFI-Auth

# password storage
# https://www.packtpub.com/books/content/storing-passwords-using-freeradius-authentication

# freeradius + openVPN
# https://www.roessner-network-solutions.com/favoriten/openvpn-radius-mysqlldap-howto/
