
# network manager plugin if needed
# aptitude install strongswan-nm

# TODO FIX: charon: 09[IKE] no private key found for '10.0.7.162'

conn roadwarrior
     #ikelifetime=60m
     #keylife=20m
     #rekeymargin=3m
     #keyingtries=1
     keyexchange=ikev2

     # left=192.168.0.100 # statically assigned
     #leftsourceip=%config                # This will take an IP from the ip pool on server
     #leftfirewall=yes

     left=10.0.7.162 # statically assigned     
     # requesting a virtual IP
     leftsourceip=%config                # This will take an IP from the ip pool on server
     # leftfirewall=yes
     
     rightauth=eap-mschapv2
     right=vpn12.unical.it   # The location of the host, FQDN or IP 
     rightid=@vpn12.unical.it # the Altname used by the ipsec host

     rightcert=vpn-server-cert.pem        # The user cert we copied in     
     rightsubnet=10.9.8.0/24          # the subnet on the servers side you want to access. 

     eap_identity=monica
     auto=start

