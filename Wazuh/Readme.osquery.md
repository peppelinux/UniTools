OSQUERY
-------

**Wazuh** setup
Da installare e attivare sulle vm degli agents e NON sul server di wazuh-manager.

````
export OSQUERY_KEY=1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $OSQUERY_KEY
add-apt-repository 'deb [arch=amd64] https://pkg.osquery.io/deb deb main'
apt-get update
apt-get install osquery
````

Dopodichè:
- In `/var/ossec/etc/ossec.conf` all'interno della sezione `<wodle name="osquery">` configurare `<disabled>no</disabled>`
- Creare una configurazione di base `cp /usr/share/osquery/osquery.example.conf /etc/osquery/osquery.conf`
- Attivare osqueryd
    ````
    systemctl enable osqueryd && systemctl start osqueryd
    ````

Il wodle osquery va abilitato nel file ossec.conf dell'agente *in alternativa* si può farlo da remoto su wazuh-manager.
Si potrebbe creare un *gruppo osquery* (agents group) in cui si mettono tutte le macchine su cui è installato osquery e si configura il relativo **agent.conf** per usare osquery.

-----------------------------------------------------------------------------------

Iniziare con OSQuery
--------------------

- Tabelle di osquery: [https://osquery.io/schema/4.3.0/](https://osquery.io/schema/4.3.0/).
- Comando: `osqueryi --config_path=/etc/osquery/osquery.conf`

See network processes
````
SELECT DISTINCT processes.uid, process_open_sockets.pid, processes.cmdline,
                process_open_sockets.remote_address, process_open_sockets.local_port, 
                process_open_sockets.remote_port
FROM process_open_sockets INNER JOIN processes 
WHERE processes.pid=process_open_sockets.pid;
````

see listening network ports
````
select listening_ports.pid, processes.cmdline, listening_ports.port,
       listening_ports.protocol, listening_ports.family, listening_ports.address
from listening_ports  INNER JOIN processes
WHERE processes.pid=listening_ports.pid AND listening_ports.address != '';
````

see arp cache
````
select * from arp_cache;
````

see ca certificates installed
````
select * from certificates;
````

connection test with curl
````
select url, round_trip_time, response_code from curl where url = 'https://github.com/facebook/osquery';
````

inspect TLS certificate
````
select * from curl_certificate where hostname = 'osquery.io';
````

inspect hostname resolvers
````
select * from dns_resolvers;
select * from etc_hosts;
````

inspect networking
````
select * from interface_addresses;
select * from interface_details;
select * from iptables;
select * from routes;
````

libmagic inspection
````
select * from magic where path = '/bin/ping';
````

suid inspection
````
select * from suid_bin;
````

sysctl
````
select * from system_controls;
````

see subscriber osquery events
````
select * from osquery_events;
````

local osquery configuration
````
select * from osquery_packs;
select * from osquery_schedule;
````

users
````
select * from shadow;
select * from last;
select * from shell_history;
select * from sudoers;
select * from users;
````

Using VirusTotal's Yara (scanner needs ruleset... TODO)
````
apt install yara
#
select * from yara where path = '/bin/ping';
````

Listening for realtime events
-----------------------------
The contents of standard tables as described above are populated when a query executes against the table. This model makes it hard to monitor system properties continually. For example, maintaining a list of running processes over time would require a user to schedule a query of the form SELECT * FROM processes at short intervals. Even then, short-lived processes might fall through the cracks.
Event-based tables address this shortcoming by collecting and storing events in near real-time. These tables ensure that events which occurr between the defined query interval are collected in the table and purged based on a user-defined expiration option.

[https://osquery.readthedocs.io/en/latest/development/pubsub-framework/](https://osquery.readthedocs.io/en/latest/development/pubsub-framework/)

Example evented tables like:
```
file_events, process_events, process_file_events, socket_events, syslog_events, user_events, yara_events
```

Execution Example
````
osqueryctl stop
osqueryi --nodisable_audit --nodisable_events --audit_allow_config=true --audit_persist=true --audit_allow_sockets --logger_plugin=filesystem --events_expiry=1

# in osquery SQL interpreter
select pid, path, cmdline, auid from process_events; 
select action, pid, path, remote_address, remote_port from socket_events;
````


Audit rules are automatically configured by osquery and can be viewed using the `auditctl` utility.
See: [https://github.com/palantir/osquery-configuration](https://github.com/palantir/osquery-configuration)

Todo
----


- only available in 4.3.0:
    1. Database of the machine's XProtect signatures: `select * from xprotect_entries where filename ...;`, xprotect_meta ...
- YARA setup and rulesets:

References
----------

- [https://medium.com/palantir/osquery-across-the-enterprise-3c3c9d13ec55](https://medium.com/palantir/osquery-across-the-enterprise-3c3c9d13ec55)
- [https://medium.com/palantir/auditing-with-osquery-part-two-configuration-and-implementation-87a8bba0ef48](https://medium.com/palantir/auditing-with-osquery-part-two-configuration-and-implementation-87a8bba0ef48)
- [https://www.linkedin.com/pulse/using-auditd-monitor-network-connections-alex-maestretti](https://www.linkedin.com/pulse/using-auditd-monitor-network-connections-alex-maestretti)
- [https://blog.rapid7.com/2016/05/09/introduction-to-osquery-for-threat-detection-dfir/](https://blog.rapid7.com/2016/05/09/introduction-to-osquery-for-threat-detection-dfir/)
