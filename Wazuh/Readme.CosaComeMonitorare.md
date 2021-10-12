Cosa e come Monitorare
----------------------

Prima di configurare gli agenti occorre sapere cosa ci gira sull'host e come monitorarlo, ma sopratutto è monitorabile?
Per rispondere a questa domanda può essere opportuno dare un occhiata alla cartella `/var/ossec/ruleset` che elenca quanto è già presente in wazuh.

- Quali oggetti voglio monitorare?
- Come ricevo i dati?

SCA
---

- https://wazuh.com/blog/security-configuration-assessment/
decidere quindi quali ruleset abilitare in `/var/ossec/ruleset/sca`

Per apparati di rete può essere opportuno seguire quanto indicato qua:

Agentless monitoring
--------------------
- https://documentation.wazuh.com/3.12/user-manual/capabilities/agentless-monitoring/index.html

Agentless monitoring allows you to monitor devices or systems with no agent via SSH, such as routers, firewalls, switches and linux/bsd systems. This allows users with software installation restrictions to meet security and compliance requirements.

Attenzione al garbage
---------------------
Buttare dentro wazuh dati che non sa masticare vuol dire che occuperanno solo spazio fino a che non si creano le rules per gestirli.
La gestione dei log suricata ne da un esempio:
https://documentation.wazuh.com/3.12/learning-wazuh/suricata.html

- Syslog può essere digerito da wazuh o da rsyslog poi riportato in wazuh. Occorre solo ricordarsi di **non fare pasticci**.
- La kibana app di wazuh e quindi la duplicazioni dei log in elk è di per se una duplicazione dei dati, ma gestire il contenuto di quei file via grep o soluzioni simili non è, a mio parere, affrontabile.


Wazuh genera un sacco di dati non utili ma sono il punto di partenza per scatenare un allarme o per trovare tracce di una compromissione/malfunzionamento. Si possono generare alert via mail quando gli alert sono di una certa importanza, al superamento di un certo score:

### Generating automatic reports
 https://documentation.wazuh.com/3.12/user-manual/manager/automatic-reports.html

### Configuring email alerts
 https://documentation.wazuh.com/3.12/user-manual/manager/manual-email-report/index.html

### Defining an alert level threshold
 https://documentation.wazuh.com/3.12/user-manual/manager/alert-threshold.html#defining-an-alert-level-threshold

Todo
----
Non ho ancora capito se viene gestita una retention sia dal punto di vista di wazuh che di elk (qui si può usare curator)


Credits
-------

Simone Bonetti