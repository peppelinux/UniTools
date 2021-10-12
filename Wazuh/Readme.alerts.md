Alerts
------

Come riceverli, filtrarli, come accedere alle informazioni utili


L'intramontabile shell. Su base today()
````
cat /var/ossec/logs/alerts/alerts.log | /var/ossec/bin/ossec-reportd -n "Daily report: Alerts with level higher than 6" -s -f level 6
````

Su base mensile
````
zcat /var/ossec/logs/alerts/2020/Apr/ossec-alerts-0*log.gz | /var/ossec/bin/ossec-reportd -n "Alerts with level higher than 6" -s -f level 6
````

Filtrare su agent (location) dev-bastion e salvare su un file
````
cat /var/ossec/logs/alerts/alerts.log | /var/ossec/bin/ossec-reportd -n "Alerts with level higher than 1" -s -f level 2 -f location dev-bastion 2&> /tmp/enrico-dev-bastion.txt
````
Attivazione allert su Telegram
````
creato script in /var/ossec/active-response/bin/ossec-telegram.sh

fonte -> https://github.com/m0zgen/ossec-to-telegram
````

Impostare permessi di esecuzione
````
chmod +x /var/ossec/active-response/bin/ossec-telegram.sh
````

Attivazione comando in osssec.conf
````
 <command>
        <name>send-telegram</name>
        <executable>ossec-telegram.sh</executable>
        <expect></expect>
  </command>

  <!--
  <active-response>
    active-response options here
  </active-response>
  -->

  <active-response>
        <command>send-telegram</command>
        <location>local</location>
        <level>6</level>
  </active-response>
  
```` 


