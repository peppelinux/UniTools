# Wazuh 3.12 SIEM

Deployment di Wazuh mediante procedure automatizzate e riproducibili.
Questo documento tiene traccia delle configurazioni, azioni e problematiche svolte, in riferimento alla guida [ufficiale di Wazuh](https://documentation.wazuh.com/3.12/) da considerare come unica fonte attendibile per i nuovi deployment.

Ambiente:
- Debian 10
- Network: 10.0.3.0/24

Nodi e schema:
- Wazuh
    - Runs the Wazuh manager and API. It collects and analyzes data from deployed agents.
    - [Wazuh Installation Guide](https://documentation.wazuh.com/3.11/installation-guide/index.html)
    - IP 10.0.3.10
- ELK cluster
    - **Must be splitted in a new machine**
    - https://documentation.wazuh.com/3.11/installation-guide/installing-elastic-stack/index.html
    - IP $
- Splunk (**not deployd yet**)
    - https://documentation.wazuh.com/3.11/installation-guide/installing-splunk/index.html
    -
- Kibana
    - **Should be splitted in a new machine**
    -

Ansible-playbook di riferimento:
- https://documentation.wazuh.com/3.11/deploying-with-ansible/index.html

### Install lxc

Istruzioni di base per l'uso di container LXC.
Aggiungere in questa sezione ulteriori altre indicazioni per l'adozione di LXD.
````
#!/bin/bash

# add LXD optionally
apt install ifupdown lxc lxctl
````

LXC host network configuration
````
# /etc/networking/interface
IFNAME=eth0

echo "
auto lxc-br0
iface lxc-br0 inet static
      address 10.0.3.1
      netmask 255.255.255.0
      bridge_ports $IFNAME
      bridge_stp off
      bridge_fd 2
      bridge_maxwait 20
" >> /etc/network/interfaces

# host sys commands for poor-man-NAT - useless with latest lxc releases and lxc-net.
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 10.0.3.10 -o ethX -j MASQUERADE
````

### Create LXC Wazuh container
````
#!/bin/bash
CNT=wazuh
CNT_IP=10.0.3.10
lxc-create  -t download -n $CNT -- -d debian -r buster -a amd64

echo '
# lxc Network configuration example
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = lxc-br0
lxc.network.name = eth0
lxc.network.hwaddr = 00:FF:AA:02:03:01
lxc.network.ipv4 = $CNT_IP/24 10.0.3.255
lxc.network.ipv4.gateway = 10.0.3.1
' >> /var/lib/lxc/$CNT/config

# Run Wazuh
lxc-start -n $CNT
lxc-attach -n $CNT
````

### Setup Wazuh in the container

In the Wazuh container.
These commands will be injected inline, via attachment command stdin.
````
# to be removed - deprecated
# echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Wazuh official repository GNUPG KEY
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -

# add apt repository
echo "deb https://packages.wazuh.com/3.x/apt/ stable main" >  /etc/apt/sources.list.d/wazuh.list

apt update
apt install -y curl apt-transport-https lsb-release gnupg2 procps htop rsyslog
apt install -y wazuh-manager
systemctl status wazuh-manager

# install Wazuh API
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt update
apt install -y gcc g++ make yarn nodejs
apt install -y wazuh-api
systemctl status wazuh-api
````

### Setup Filebeat
https://documentation.wazuh.com/3.12/installation-guide/installing-wazuh-manager/linux/debian/wazuh_server_packages_deb.html#installing-filebeat
````
apt install -y curl apt-transport-https
curl -s https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list
apt update
apt install -y filebeat=7.6.1

# Download the Filebeat config file from the Wazuh repository. This is pre-configured to forward Wazuh alerts to Elasticsearch:
curl -so /etc/filebeat/filebeat.yml https://raw.githubusercontent.com/wazuh/wazuh/v3.12.0/extensions/filebeat/7.x/filebeat.yml

# Download the alerts template for Elasticsearch:
curl -so /etc/filebeat/wazuh-template.json https://raw.githubusercontent.com/wazuh/wazuh/v3.12.0/extensions/elasticsearch/7.x/wazuh-template.json

# Download the Wazuh module for Filebeat
curl -s https://packages.wazuh.com/3.x/filebeat/wazuh-filebeat-0.1.tar.gz | tar -xvz -C /usr/share/filebeat/module

# Edit the file /etc/filebeat/filebeat.yml and replace YOUR_ELASTIC_SERVER_IP with the IP address or the hostname of the Elasticsearch server
# future:
# sed -i 's\YOUR_ELASTIC_SERVER_IP\$CNT_IP\g'  /etc/filebeat/filebeat.yml
# all in a vm:
sed -i 's\YOUR_ELASTIC_SERVER_IP\127.0.0.1\g'  /etc/filebeat/filebeat.yml

systemctl daemon-reload
systemctl enable filebeat.service
systemctl start filebeat.service
````

### Setup ElasticSearch
````
apt install -y curl apt-transport-https
curl -s https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list
apt update
apt install -y elasticsearch=7.6.1

# Elasticsearch will only listen on the loopback interface (localhost) by default.
# Configure Elasticsearch to listen to a non-loopback address by editing the file /etc/elasticsearch/elasticsearch.yml and uncommenting the setting network.host.

# TODO ...

systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

# Once Elasticsearch is up and running, it is recommended to load the Filebeat template. Run the following command where Filebeat was installed
filebeat setup --index-management -E setup.template.json.enabled=false
````

### Setup Kibana
````
apt install -y kibana=7.6.1 sudo libnss3

# Install the Wazuh app plugin for Kibana
pushd /usr/share/kibana/
sudo -u kibana bin/kibana-plugin install https://packages.wazuh.com/wazuhapp/wazuhapp-3.12_0_7.6.1.zip
popd

# Kibana will only listen on the loopback interface (localhost) by default, which means that it can be only accessed from the same machine.
# To access Kibana from the outside make it listen on its network IP by editing the file /etc/kibana/kibana.yml, uncomment the setting server.host, and change the value to
sed -i "s/server.host: \"localhost\"/server.host: \"$CNT_IP\"/g" /etc/kibana/kibana.yml

# Configure the URLs of the Elasticsearch instances to use for all your queries. By editing the file /etc/kibana/kibana.yml
# elasticsearch.hosts: ["http://<elasticsearch_ip>:9200"]

# if all in or in different hosts, manage this VAR
CNT_IP=localhost
sed -i "s|#elasticsearch.hosts: \[\"http://localhost:9200\"\]|elasticsearch.hosts: \[\"http://$CNT_IP:9200\"\]|g" /etc/kibana/kibana.yml

systemctl daemon-reload
systemctl enable kibana.service
systemctl start kibana.service
````

## Trouble shooting

#### FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed - JavaScript heap out of memory
remember to set this threshold otherwise Debian10 gets __"FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed - JavaScript heap out of memory"__ when kibana starts

- echo 'NODE_OPTIONS="--max_old_space_size=4096"' >> /etc/default/kibana
- in modify /etc/systemd/system/wazuh-api.service to `ExecStart=/usr/bin/nodejs --max-old-space-size=4096 /var/ossec/api/app.js~


wazuh-api plugin configuration in kibana:
- /usr/share/kibana/plugins/wazuh/wazuh.yml

#### 3005 - Invalid 'wazuh-app-version' header. Expected version '3.12.x
If Kibana fails to connect to wazuh api with this error: "3005 - Invalid 'wazuh-app-version' header. Expected version '3.12.x', and found '3.11.x'."
````
systemctl stop kibana
cd /usr/share/kibana
sudo -u kibana /usr/share/kibana/bin/kibana-plugin remove wazuh
rm -rf /usr/share/kibana/optimize/bundles
sudo -u kibana /usr/share/kibana/bin/kibana-plugin install https://packages.wazuh.com/wazuhapp/wazuhapp-3.12.0_7.6.1.zip #7.6.1 is the kibana version!
systemctl start kibana
````

#### 3005 - Wrong protocol being used to connect to the Wazuh API
- fix connection configuration in: `/usr/share/kibana/optimize/wazuh/config/wazuh.yml`


#### Data too large, data for [<http_request>] would be

in `/etc/default/elasticsearch`:

# HEAP up to 10G to avoid
ES_JAVA_OPTS="-Xms10g -Xmx10g"

Attenzione non superare i 32GB, come indicato qui:
https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html

## In caso di errori Kibana side tipo "104 of 348 shards failed"

Controllare lo stato degli shards
````
curl -XGET http://172.16.16.253:9200/_cat/shards?v
````

Eventualmente aggiungere ram (JVM HEAP UP to N) e assegnare gli shards non avviati a specifici nodi del cluster (se single node cluster vedi tip successivo).

## Single node cluster (ELK)

If you're running a single node cluster for some reason, you might simply need to do avoid replicas, like this:

````
curl -XPUT -H 'Content-Type: application/json' 'http://172.16.16.253:9200/_settings' -d '
{
    "index" : {
        "number_of_replicas" : 0
    }
}'
````

### Buone pratiche
Si chiamano backup e non passano mai di moda.

Qui la lista di azioni per il backup delle varie entità e configurazioni.
Tutta la configurazione di Wazuh sta in `/var/ossec`.

- Backup agents: `cat /var/ossec/etc/client.keys`. Leggi [Recupero Agents](Readme.Rescue-Agents.md )
- Disabilitare il check dei filechange su directory particolari, esempio aggiungere `<ignore>/etc/.git</ignore>` nella sezione `<syschecks>` in ossec.conf (o agents.conf)
- TODO: serve backup/ripristino dati storici
- Backup/ripristino ELK (vedi elk/)


### Cose da NON-FARE
Che se le fai te ne penti.

- installare wazuh-agent sulla stessa vm dove risiede wazuh-manager
- installare osquery sulla stessa vm dove risiede wazuh-manager
- disinstallare/reinstallare wazuh-manager con un comando arbitrario tipo `apt install -y wazuh-agent` eseguito sulla VM dove risiede wazuh-manager. Ricorda, troverai il backup dei tuoi clients in `/var/ossec/etc/client.keys.save`

### Wodles

Vedi il file [agent.conf](agent.conf) per creare gruppi di agent, aggiornarli e abilitare i wodles per ogni gruppo.
Vedi REadme dedicati ai Wodles.

**NOTA BENE** meglio disabilitare gli aggiornamenti autormatici degli agents sui vari client e aggiornare esclusivamente da remoto via wazuh-manager.


### Remote commands
Abilitarla o meno può precludere l'accesso alle vm, se gli agent ricevono un comando di firewall drop sul tuo ip ad esempio.

Abilitare la gestione remota ( [doc](https://documentation.wazuh.com/3.12/user-manual/reference/ossec-conf/wodle-command.html#centralized-configuration))
sugli hosts dove sono installati gli agents modificare in `etc/local_internal_options.conf` `wazuh_command.remote_commands=1`

### Aggiornare periodicamente decoders e ruleset

````
@weekly root cd /var/ossec/bin && ./update_ruleset -r
````

### Todo:
- [Securing Wazuh-API](https://documentation.wazuh.com/3.11/installation-guide/securing_api.html#securing-api)
- It is recommended that the Wazuh repository be disabled in order to prevent accidental upgrades:
    ````
    sed -i "s/^deb/#deb/" /etc/apt/sources.list.d/wazuh.list
    apt-get update
    # Alternately, you can set the package state to hold, which will stop updates (although you can still upgrade it manually using apt-get install).
    # echo "wazuh-manager hold" | sudo dpkg --set-selections
    # echo "wazuh-api hold" | sudo dpkg --set-selections
    ````
- Disable the Elasticsearch updates. It is recommended that the Elasticsearch repository be disabled in order to prevent an upgrade to a newer Elastic Stack version due to the possibility of undoing changes with the App. To do this, use the following command:
    ````
    # sed -i "s/^deb/#deb/" /etc/apt/sources.list.d/elastic-7.x.list
    # apt-get update
    Alternately, you can set the package state to hold, which will stop updates (although you can still upgrade it manually using apt-get install).


    # echo "elasticsearch hold" | sudo dpkg --set-selections
    # echo "kibana hold" | sudo dpkg --set-selections
    ````

### Ansible Wazuh Agents provisioning
- [autodeploy-machine-garrlab](https://gitlab.garrlab.it/ansible/autodeploy-machine-garrlab/)

### Registering new agents
- https://documentation.wazuh.com/3.12/user-manual/registering/index.html
- https://gist.github.com/michelep/19080a758c13a8df6b08f3dcaf0f2609

### Additonal resources

- [car.mitre.org](https://car.mitre.org/)
- [Scaling SecurityOnion](https://blog.securityonion.net/2020/03/security-onion-at-scale-18x.html)
