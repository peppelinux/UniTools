IPSEC ike2-mschap2 strongswan universal setup
=====================================

These scripts are based on this tutorial and some others commented in ipsec.sh file.

https://www.digitalocean.com/community/tutorials/how-to-set-up-an-ikev2-vpn-server-with-strongswan-on-ubuntu-16-04

you can even test this configuration with these embedded firmwares as VPN clients:
https://github.com/peppelinux/pplnx-LEDE-firmwares

Setup
=====

Tested as fully working with:
````
Linux strongSwan U5.2.1/K3.16.0-4-amd64
Linux strongSwan U5.5.1/K4.9.0-3-amd64
````

First of all change vars as you prefer in ipsec.sh file.
You can decide to reuse already (self-)signed certs or create them automatically.
If you want to create them from scratch simply do this:

````
# this var in ipsec.sh
BUILD_CA_CERTS="0"

#to
BUILD_CA_CERTS="1"
````

If you want to deploy strongswan with Let'sEncrypt certificates you should use the following pattern in /etc/ipsec.d/ folder:
````
cacerts/server-root-ca.pem -> /etc/letsencrypt/live/vpn.unical.it/chain.pem
certs/vpn-server-cert.pem -> /etc/letsencrypt/live/vpn.unical.it/fullchain.pem
private/vpn-server-key.pem -> /etc/letsencrypt/live/vpn.unical.it/privkey.pem
````

Then run ipsec.sh for strongswan setup and ipsec.fw.sh for firewall, NAT and kernel routing sysctl rules.

Once strongwan beign started you can copy $SERVER_CA_CERT to your clients.
In clients/ folder there are some examples, test log and screenshots, hope you enjoy.

For Linux strongswan clients the $SERVER_CA_CERT must be copied in

````
/etc/ipsec.d/certs/cacerts
````


Troubleshooting
===============

````
problem:
 EAP_IDENTITY not supported, sending EAP_NAK
 
solution:
  mschap-v2 module is missing. This can be checked using ipsec statusall | grep mschap
  on debian 9: apt-get install libcharon-extra-plugins strongswan-ikev2

````

````
problem:
  Authentication is successful, but then the connection drops with errors like the ones below.
  Jul 23 02:11:12 stretch charon: 05[IKE] traffic selectors 10.9.8.0/24 === 10.0.7.162/32 inacceptable
  Jul 23 02:11:12 stretch charon: 05[IKE] failed to establish CHILD_SA, keeping IKE_SA

solution:
  just add leftsourceip= %config OR x.y.z.n in client ipsec.conf conn
````

## Known Issues

The built-in VPN client in Windows does not support IKEv2 fragmentation. On some networks, this can cause the connection to fail or have other issues. You may try <a href="clients.md#troubleshooting" target="_blank">this registry fix</a>, or connect using <a href="clients.md" target="_blank">IPsec/L2TP</a> or <a href="clients-xauth.md" target="_blank">IPsec/XAuth</a> mode instead.
