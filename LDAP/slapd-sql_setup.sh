#!/bin/bash
set -e 
set -x

VERSION="openldap-2.4.45"
DBNAME="openldap"
DBUSER="openldap"
DBPASSWD="change_me_soon"

apt install unixodbc-dev unixodbc libsasl2-dev gnutls-dev

wget ftp://mirror.switch.ch/mirror/OpenLDAP/openldap-release/$VERSION.tgz
tar zxvf openldap-*.tgz
cd $VERSION

./configure --prefix=/usr --exec-prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --localstatedir=/var --mandir=/usr/share/man --infodir=/usr/share/info --enable-sql --disable-bdb --disable-ndb --disable-hdb
make depend
make install

# now configure slapd, first create the root password with slappasswd
read PASSWD
HASHED_PASSWD=$(slappasswd -s "$PASSWD")

# slapd configuration
nano /etc/openldap/slapd.conf

# replace with SQL database definition
echo '
#######################################################################
# sql database definitions
#######################################################################
database sql
suffix "dc=life,dc=com"
# Only need if not using the ldbm/bdb stuff below
rootdn "cn=manager,dc=life,dc=com"
rootpw '${HASHED_PASSWD}'
dbname '${DBNAME}'
dbuser '${DBUSER}'
dbpasswd '${DBPASSWD}'
has_ldapinfo_dn_ru no
subtree_cond "ldap_entries.dn LIKE CONCAT('%',?)"' > slapd.sql.conf

# log levels are
# 1	trace function calls
# 2	debug packet handling
# 4	heavy trace debugging
# 8	connection management
# 16	print out packets sent and received
# 32	search filter processing
# 64	configuration file processing
# 128	access control list processing
# 256	stats log connections/operations/results
# 512	stats log entries sent
# 1024	print communication with shell backends
# 2048	entry parsing

# start
slapd -d 5 -h 'ldap:/// ldapi:///' -f /etc/openldap/slapd.conf &
