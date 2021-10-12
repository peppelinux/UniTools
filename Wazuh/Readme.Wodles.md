Wazuh, Capabilities, wodle, integration, extensions
-------------------------------------
capabilities: wodle, integration

wodle: open-scap, cis-cat, osquery, syscollector, aws, docker, azure, gcloud....

integration: virustotal


Cosa sono i wodle, le integration e le extension?

Si potrebbero definire come dei plugin di wazuh per estenderne le funzionalità.
I wodle sono attivabili/disattivabili su wazuh-agennt e su wazuh-master (in questo caso spesso fanno la vece del wazuh-agent per il master, lo monitorano).
Le integration (virustotal) si attivano solo su wazuh-manager.
Le extension sono il concetto di wodle e integration applicato alla wazuh kibana app. In pratica determinano la loro visibilità all'interno dell'app. Più avanti sarà più chiaro

I wodle importanti sono attivi di default. Prima di procedere ad attivarne altri valutate se il livello di analisi raggiunto vi soddisfa o è carente.
Ogni loro attivazione|configurazione conviene farla in modo centralizzato da wazuh-manager.

Al momento dell'installazione (wazuh-manager o wazuh-agent) viene identificato un profilo che meglio si adatta all'architettura.
Tale profilo , visibile facilmente nella configurazione dell'agent, può essere identificato/definito in due modi (file ossec.conf):
*  tramite la direttiva config-profile, es: <config-profile>ubuntu, ubuntu16, ubuntu16.04</config-profile>
*  tramite il tag profile, es: <agent_config profile="nomedelprofilo">

Attenzione a non mescolare le direttive dei profili.


Partendo dalla GUI (wazh kibana app)
------------------
Siete in overview, nei quattro riquadri riepilogativi delle funzionalità di wazuh trovate una icona a forma di occhio. Clickatela e attivate la visualizzazione dei wodle/integration. 

Non funziona o non li vede tutti? Seguite quanto descritto qua:
	https://documentation.wazuh.com/3.12/installation-guide/installing-elastic-stack/automatic_api.html
Il tutto impatta o ha a che fare con il seguente file:
	`/usr/share/kibana/optimize/wazuh/config/wazuh.yml`

Panoramica su alcuni wodle e consigli d'uso
------------------
Security Configuration Assessment
------------------
Non si tratta di un vero è proprio wodle ma di un modulo di wazuh che integra le sue valutazioni con quelle provenienti da tre woodle:
* OpenSCAP disponibile solo per linux
* Rootcheck che dipende da Syscheck daemon, purtroppo è un po' datato e può generare falsi positivi. Attivato al momento dell'installazione di wazuh-agent
* CIS-CAT tool si tratta di un software proprietario per il quale è richiesto il pagamento di una licenza

Le valutazioni fatta dal modulo sca dipendono dalle policy che trovate in /var/ossec/ruleset/sca/ e rappresentano i test che verrannno eseguiti sull'agente per valutarne la sua configurazione (assesment).

Tali policy sono mantenute dagli sviluppatori di wazuh, la maggior parte deriva dai CIS benchmark ([elenco completo](https://documentation.wazuh.com/3.12/user-manual/capabilities/sec-config-assessment/how_to_configure.html#available-sca-policies)). Sono le più facili da usare e le più comprensibili.

Se controllate la stessa cartella su di un agent troverete quelle che sono state dedotte in fase di installazione e che meglio possono testare la macchina su cui sta girando wazuh-agent.
Le policy sca possono essere abilitate/disabiitate con la direttiva `<policy enabled="no">/var/ossec/etc/shared/policy_file_to_disable.yml</policy>` o rinominando il file della policy aggiungendo .disabled.
Possono essere distribuite centralmente nel file agent.conf del gruppo di appartenenza.

Nel caso di una macchina ubuntu troverete policy definite per debian. SCA nasce con l'idea di superare le limitazioni dei tre wodle indicati sopra, ma si integra perfettamente con essi.

Openscap
------------------
SCAP sta per Security Content Automation Protocol,  uno standard aperto che definisce metodi per policy compliance, vulnerability management, assesmentn, ecc..
Proviamo ad estendere la valutazione di una macchina ubuntu con il wodle open-scap

Anche qui wazuh fornisce le policy per open-scap, ma ahinoi non sono aggiornatissime (su wazuh-agent /var/ossec/wodles/oscap/content/ e la stessa cartella su wazuh-manager per vedere tutte quelle supportate).
Questo fa pensare che alcuni controlli potrebbero non essere adeguatamente supportati in fase di gestione degli eventi.

Per ubuntu (penso si possa dire lo stesso per debian) occorrono i seguenti pacchetti:
`sudo apt install libopenscap8 xsltproc`

per ubuntu 18.04 può essere interessante installare anche i seguenti pacchetti:
`sudo apt install ssg-applications ssg-base ssg-debderived ssg-debian ssg-nondebian`

Per capire cosa contengono i file di policy occorre usare il seguente comando:
`oscap info /var/ossec/wodles/oscap/content/ssg-ubuntu-1604-ds.xml`

Tra le tante righe che trovate date un occhiata alla lista della voce Profiles: è la lista dei test che volete condurre sulla vostra macchina.
Scegliete quello che megio si adatta alla vostre esigenze.

Dopo aver fatto la scelta dovrete definire la configurazione del wodle che vi conviene deployare da wazuh-manger.
Nel mio caso, per una ubuntu 16.04, ho aggiunto al file agent.conf del gruppo col quale la distribuirò, la seguente configurazione:

```
<wodle name="open-scap">
  <disabled>no</disabled>
  <timeout>1800</timeout>
  <interval>1d</interval>
  <scan-on-start>yes</scan-on-start>
  <content type="xccdf" path="ssg-ubuntu-1604-ds.xml">
    <profile>xccdf_org.ssgproject.content_profile_common</profile>
    <profile>xccdf_org.ssgproject.content_profile_anssi_np_nt28_high</profile>
  </content>
  <content type="oval" path="cve-ubuntu-xenial-oval.xml"/>
</wodle>
```


In questo caso siamo fortunati perché abbiamo le policy adatte alla nostra configurazione, come fare se non siamo così fortunati?
Come detto sopra ubuntu 18.04 fornisce alcuni pacchetti che possono aiutarci.
Basterà prendre i file delle policy che vogliamo applicare e inserirli nella cartella indicata sopra dell'agente: aggiustate l'ownership.

Purtroppo non sono presenti i file per ubutu 18.04.
In questo caso potete rivolggervi direttamente alla fonte per il file ssg: https://github.com/ComplianceAsCode/content/releases
Per il file cve usate le indicazioni riportate qua: https://people.canonical.com/~ubuntu-security/oval/

Riferimenti
* sca: https://documentation.wazuh.com/3.12/user-manual/capabilities/sec-config-assessment/#manual-sec-config-assessment 
* openscap su windows basato su cygwin: https://static.open-scap.org/openscap-1.2/oscap_user_manual.html#_building_openscap_on_windows (?)
* cve per ubuntu: https://people.canonical.com/~ubuntu-security/oval/
* scap e debian: https://wiki.debian.org/UsingSCAP


Rootcheck
------------------
Questo componente di wazuh è un po' datato e pian piano verrà sostituito da sca.
Si occupa di fare un assesment del dispositivo su cui gira l'agente. Tali controlli si trovano nella cartella /var/ossec/etc/rootcheck/ (wazuh-manager)
Gli unici che vale la pena di usare, anche se datati, e che sono attivi di default sono: rootkit_files.txt, rootkit_trojans.txt and win_malware_rcl.txt.

Attivare gli altri è possibile ma si riceverà un messaggio simile a questo:
`ossec-syscheckd: WARNING: The check_unixaudit option is deprecated in favor of the SCA module.`

Osquery
------------------
Tutto quello che dovete fare è descritto qui: https://documentation.wazuh.com/3.12/user-manual/capabilities/osquery.html

Per poterlo "vedere" in kibana occorre distribuire la seguente direttiva inserendola nel file agent.conf

`<wodle name="osquery"/>`






