Disaster recovery degli Agents
------------------------------

La vita e la salute delle connessioni degli agents si può ricavare qui:
````
cat /var/ossec/logs/ossec.log | grep -i -E "(error|warn)"
````

Nel caso in qui rilevassimo la dicitura, una o più diciture `Invalid ID 001 for the source ip ... `.
Questo significa che abbiamo compromesso un agent centralmente, ad esempio:

- reinstallando wazuh-server
- un agent non registrato si comporta come se lo fosse.


# Wazuh tools

Comandi utili per la diagnosi

- /var/ossec/bin/manage_agents
- /var/ossec/bin/agent_control -l


#### Fare i backup 

I client id e chiavi possono essere backuppati copiando `/var/ossec/etc/client.keys` da wazuh-manager oppure
raccogliendo per ogni agent `ossec-agent/client.key`. Il formato è il seguente:

`011 munin any 3398ee5c5055cfee723f80edc74996a13d9c46a9ead9e7e157d2cb291f0649fb`


#### Analisi gestione Agents

Nel server Wazuh-manager per ogni agent registrato (manage_agents) 
otteniamo una corrispondeza nel file `etc/client.keys` e un db SQLite (SQLite 3.x database),
esempio `/var/ossec/var/db/agents/003-dev-bastion.db`. 


La gestione degli agent registrati avviene in `/var/ossec/var/db/` nel file `global.db` o `global.sql`. Segue un esempio di interrogazione a questo db:

````
apt install -y sqlite3
sqlite /var/ossec/var/db/global.sql|db

# in sqlite shell:
.tables
select * from agent;

# output
4|dev-bastion||any|267101f8f438123198a8577641e546c56a637a96abe7cf4121c6d041ed23d6bc||||||||||||||unknown|1585666278||empty|0|0|
````

### Nota bene
Se estraggo la chiave di 004 con `/var/ossec/bin/manage_agents -e 004`, Ottengo:
  - MDA0IGRldi1iYXN0aW9uIGFueSAyNjcxMDFmOGY0MzgxMjMxOThhODU3NzY0MWU1NDZjNTZhNjM3YTk2YWJlN2NmNDEyMWM2ZDA0MWVkMjNkNmJj

Questo altro non è che un Base64 di:
  - '004 dev-bastion any 267101f8f438123198a8577641e546c56a637a96abe7cf4121c6d041ed23d6bc'

Hints:
  - vedi i nomi delle colonne della tabella agent di global.md: `.schema agent`
  - cancella un inserimento errato `DELETE FROM agent WHERE id=4;`
    
### Ripristino Agents da backup

1. Stop di wazuh `/etc/init.d/wazuh-manager stop`
2. Ripristino chiavi ed indentificativi `cat /var/ossec/etc/client.keys.save > /var/ossec/etc/client.keys`
3. Update manuale della base dati aiutandoci con un python script

Python Script
````
client_content = """001 dev-bastion any 994ab85cba7ab2e697e582a9e027082678a3169b763c2559c4a40a347d2f364a
002 pdns-admin any 42619fff807251c498d9b1d5165730c224c10e46851fcaee42f794615be749e8
003 gitlab any 8d7058e68fa01ffefe9919d8988d41651da88997be3f8da8e77809181f8d7f36
004 garr-bar-devel any 371baf5eacd4564d98bf4ff5abcdf915e5ddc100cb935e751bf15d619cad9663
005 telegram-gw any 32a31b2f4153555283166cd78e3433601d2fbaddf922f7d256be9b40450afcdf
006 pgdb-01 any befb0c5914a1db4837576c01030ebad2ad08518f7c96a05512a1dacf97b36d34
007 gw.garrlab.it any 2086bdfda31b142d029019218fc4245d24ba3e2366d0137fb422efbf42f07438
008 powerdns-as any 4fe5486a84364317a5a656f9991343081c34be4674da1e3bc6f1690f001d2c48
009 appnode-02-prod any ca63d6665549cad7347a4f42e2a19053106d51c8e8266a1c3c04d0e6fb244851
010 kea-dhcpd any 3472e400eda370b6e274b54ef9b11edd86942952d010fcd42ca651ee9e38e0c6
011 munin any 3398ee5c5055cfee723f80edc74996a13d9c46a9ead9e7e157d2cb291f0649fb
012 appnode-01-prod any a810d933b7bac4cae4384d85e5b32a67c02e15ee0d574a9226646cf737b1c5ae"""


CREATED_TIMESTAMP = 1585665278

insert_tmpl = """
insert into agent ('id', 'name', 'register_ip', 'internal_key', 'date_add')
values ({}, '{}', '{}', '{}', '{}');
"""

for i in client_content.splitlines():
    row = i.split(' ')
    res = insert_tmpl.format(int(row[0]), row[1], row[2],
                             row[3], CREATED_TIMESTAMP)
    print(res)
````

Lo script torna tante query di inserimento da copia incollare nella shell di sqlite3.
Verificare in seguito gli inserimenti con i comandi:

- `/var/ossec/bin/agent_control -l`

Avviare dunque Wazuh-manager.
