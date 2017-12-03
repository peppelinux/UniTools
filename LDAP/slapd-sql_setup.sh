#!/bin/bash
set -e 
set -x

VERSION="openldap-2.4.45"

apt install unixodbc-dev unixodbc 

wget ftp://mirror.switch.ch/mirror/OpenLDAP/openldap-release/$VERSION.tgz
tar zxvf openldap-*.tgz
cd openldap-*

./configure --prefix=/usr --exec-prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --localstatedir=/var --mandir=/usr/share/man --infodir=/usr/share/info --enable-sql --disable-bdb --disable-ndb --disable-hdb
make depend
make install

