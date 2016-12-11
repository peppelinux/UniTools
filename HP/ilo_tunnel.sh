#!/bin/bash

# once connected we can access ilo remote screen through firefox and java 1.8.
# remember to whitelist the certificate

export SSHADDR='160.x.t.u'
export IPADDR='10.x.y.z'

ssh root@$SSHADDR -L \*:2222:$IPADDR:22 -L \*:23:$IPADDR:23 -L \*:80:$IPADDR:80 -L \*:3389:$IPADDR:3389 -L \*:443:$IPADDR:443 -L \*:17988:$IPADDR:17988 -L \*:17990:$IPADDR:17990 -L \*:9300:$IPADDR:9300 -L \*:3002:$IPADDR:3002
