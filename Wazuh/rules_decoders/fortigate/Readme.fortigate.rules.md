Fortigate in wazuh
------------------
Thank to https://github.com/wazuh/wazuh-kibana-app/issues/1884

Enabling Fortigate syslog to Wazuh
----------------------------------

in `/var/ossec/etc/ossec.conf` confiure your embedded wazuh syslog.
````
<remote>
  <connection>syslog</connection>
  <port>514</port>
  <protocol>udp</protocol>
  <allowed-ips>10.0.0.0/24</allowed-ips>
  <local_ip>10.0.0.1</local_ip>
</remote>
````


Custom Decoder
-------------

Add custom_fortigate_decoders.xml to `/var/ossec/etc/decoders/`

Custom Rule
-----------

Add custom_fortigate_rules.xml `/var/ossec/etc/rules/`


Adjust the permissions and owner for the custom rules file
````
# chown ossec:ossec /var/ossec/etc/rules/custom_fortigate_rules.xml
# chmod 660 /var/ossec/etc/rules/custom_fortigate_rules.xml
````

I recommend you to check the custom rules, its syntax and think if there is something missing. 
I think that with these examples you can easily add your own rules. 
You can use /var/ossec/bin/ossec-logtest, 
our log testing binary where you can enter a logs and see if it triggers a decoder or/and an alert.