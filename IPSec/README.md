IPSEC ike2 strongswan setup based on 

https://www.digitalocean.com/community/tutorials/how-to-set-up-an-ikev2-vpn-server-with-strongswan-on-ubuntu-16-04

TROUBLESHOOTING

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

