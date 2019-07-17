#!/bin/bash
# Copyright (C) 2017  <giuseppe.demarco@unical.it>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

set -x
# set -e

export DEST_DIR=/etc/syslog-ng/ca.d
export TERENA_FNAME=TERENA_SSL_CA_3.pem
export TERENA_CA_URL=https://www.terena.org/activities/tcs/repository-g3/$TERENA_FNAME
export DIGICERT_FNAME=DigiCertAssuredIDRootCA.crt
export DIGICERT_CA_URL=https://www.digicert.com/CACerts/$DIGICERT_FNAME
export SYSLOG_CONF_PATH=/etc/syslog-ng/conf.d
export UNICAL_SERVER=log.unical.it

apt update
apt install syslog-ng-core syslog-ng-mod-sql syslog-ng-mod-mongodb \
syslog-ng-mod-smtp syslog-ng-mod-amqp syslog-ng-mod-geoip \
syslog-ng-mod-redis syslog-ng-mod-stomp

rm -Rf $DEST_DIR
mkdir -p $DEST_DIR
cd $DEST_DIR

# these prevents CA http connection timeout/error
while [ ! -f $TERENA_FNAME ] ;
do
      wget $TERENA_CA_URL
done

while [ ! -f $DIGICERT_FNAME ] ;
do
      wget $DIGICERT_CA_URL
done

TERENA_UID=`openssl x509 -noout -hash -in $TERENA_FNAME`
ln -fs $TERENA_FNAME $TERENA_UID.0

# crt to pem conversion
DIGICERT_CA_PEM=$(echo $DIGICERT_FNAME | sed 's|\.crt||g').pem
openssl x509 -in $DIGICERT_FNAME -inform der -outform pem -out $DIGICERT_CA_PEM
DIGICERT_UID=`openssl x509 -noout -hash -in $DIGICERT_CA_PEM`
ln -fs $DIGICERT_CA_PEM $DIGICERT_UID.0

# Successivamente bisogna modificare il file di configurazione syslog-ng.conf.
echo 'source Unical_auth {file("/var/log/auth.log");};

filter f_Unical {
   match(" session opened for user " value("MESSAGE")) or
   match(" session closed for user " value("MESSAGE"));
};

destination Unical_tls_destination {
syslog("'$UNICAL_SERVER'" 
port(6517) 
transport("tls")
tls( ca-dir("'$DEST_DIR'")) 
   );
  };

log { 
   source(Unical_auth); 
   filter(f_Unical);  
   destination(Unical_tls_destination); 
};' > $SYSLOG_CONF_PATH/unical_auth.conf

# restart syslog-ng :)
service syslog-ng restart
