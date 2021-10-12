Gestione centralizzata degli agenti
-----------------------------------

Ogni agente può appartene ad uno o più gruppi. L'apparteneza a tali gruppi gli fa ereditare rules e configurazioni.
Questo è documentato al seguente link:
https://documentation.wazuh.com/3.7/user-manual/reference/centralized-configuration.html#centralized-configuration-agent-conf

Di seguito un estrazione delle parti più interessanti ed eventuali commenti/integrazioni. Invitiamo sempre a seguire la guida perché è continuamente aggiornata. Scriverne una "parallela" può fuorviare perché l'esecuzione di certi comandi o anche la posizione di un file può cambiare da versione a versione.

When setting up remote commands in the shared agent configuration, you must enable remote commands for Agent Modules. This is enabled by adding the following line to the /var/ossec/etc/local_internal_options.conf file in the agent:
wazuh_command.remote_commands=1

Agent groups
------------
Agents can be grouped together in order to send them unique centralized configuration that is group specific. Each agent can belong to more than one group and unless otherwise configured, all agents belong to a group called default.

The manager pushes all files included in the group folder to the agents belonging to this group. For example, all files in /var/ossec/etc/shared/default will be pushed to all agents belonging to the default group.

In case an agent is assigned to multiple groups, all the files contained in each group folder will be merged into one, and subsequently sent to the agents, being the last one the group with the highest priority.

The file ar.conf (active response status) will always be sent to agents even if it is not present in the group folder.

The agent will store the shared files in /var/ossec/etc/shared, not in a group folder.


### agent.conf
The agent.conf is only valid on server installations.
The agent.conf may exist in each group folder at `/var/ossec/etc/shared`.

1. create a group and edit. Each of these files should be readable by the ossec user.

2. run `/var/ossec/bin/verify-agent-conf`:
Each time you make a change to the agent.conf file, it is important to check for configuration errors. If any errors are reported by this check, they must be fixed before the next step. Failure to perform this step may allow errors to be pushed to agents which may prevent the agents from running. At that point, it is very likely that you will be forced to visit each agent manually to recover them.

3. Push the configuration to the agents:
With every agent keepalive (10 seconds default), the manager looks to see if a new version of agent.conf is available. When a new version is available, it automatically pulls the new file. However, the new agent.conf is not used by the agent until the next time the agent is restarted, as in step 5.

Note
Restarting the manager will make the new agent.conf file available to the agents more quickly.

4. Confirm that the agent received the configuration:
The agent_groups tool or the API can show whether the group is synchronized in the agent, by wazuh-api

```` 
curl -u foo:bar -X GET "http://localhost:55000/agents/001/group/is_sync?pretty"
{
    "error": 0,
    "data": {
        "synced": true
    }
}
````
````
# or by agent_groups
/var/ossec/bin/agent_groups -S -i 001
# Output
Agent '001' is synchronized.
````

5. Restart the agent:
By default, the agent restarts by itself automatically when it receives a new shared configuration.
If auto_restart has been disabled (in the <client> section of Local configuration), the agent will have to be manually restarted so that the new agent.conf file will be used. This can be done as follows:

````
/var/ossec/bin/agent_control -R -u 1032
# Output
Wazuh agent_control: Restarting agent: 1032
````

### Precedence
The configuration located at agent.conf will overwrite the one of the ossec.conf.

### How to ignore shared configuration
Whether for any reason you don’t want to apply the shared configuration in a specific agent, it can be disabled by adding the following line to the `/var/ossec/etc/local_internal_options.conf` file in that agent:
`agent.remote_conf=0`


Download [configuration files from remote location](https://documentation.wazuh.com/3.12/user-manual/reference/centralized-configuration.html#download-configuration-files-from-remote-location). Wazuh manager has the capability to download configuration files like `merged.mg` as well as other files to be merged for the groups that you want to. To use this feature, we need to put a yaml file named `files.yml` under the directory `/var/ossec/etc/shared/`. When the manager starts, it will read and parse the file.
The `files.yml` has the following structure as shown in the following example:

````
----begin
groups:
    my_group_1:
        files:
            agent.conf: https://example.com/agent.conf
            rootcheck.txt: https://example.com/rootcheck.txt
            merged.mg: https://example.com/merged.mg
        poll: 15

    my_group_2:
        files:
            agent.conf: https://example.com/agent.conf
        poll: 200

agents:
    001: my_group_1
    002: my_group_2
    003: another_group
----end
````

Here we can distinct the two main blocks: **groups** and **agents**.
In the groups block we define the group name from which we want to download the files.
 - If the group doesn’t exists, it will be created.
 - If a file has the name merged.mg, only this file will be downloaded. Then it will be validated.
 - The poll label indicates the download rate in seconds of the specified files.

In the agents block, we define for each agent the group to which we want it to belong.
This configuration can be changed on the fly. The manager will reload the file and parse it again so there is no need to restart the manager every time. The information about the parsing is shown on the `/var/ossec/logs/ossec.log` file. For example:

````
Parsing is successful:
 INFO: Successfully parsed of yaml file: /etc/shared/files.yml
File has been changed:
 INFO: File '/etc/shared/files.yml' changed. Reloading data
Parsing failed due to bad token:
 INFO: Parsing file '/etc/shared/files.yml': unexpected identifier: 'group'
Download of file failed:
 ERROR: Failed to download file from url: https://example.com/merged.mg
Downloaded merged.mg file is corrupted or not valid:
 ERROR: The downloaded file '/var/download/merged.mg' is corrupted.
````

Internal configuration
----------------------
The main configuration is located in the ossec.conf file, however some internal configuration features are located in the /var/ossec/etc/internal_options.conf file.
Generally, this file is reserved for debugging issues and for troubleshooting. Any error in this file may cause your installation to malfunction or fail to run.
Warning
 This file will be overwritten during upgrades. In order to maintain custom changes, you must use the /var/ossec/etc/local_internal_options.conf file.


Unattended Installation
-----------------------
The unattended installation saves time deploying agents, allowing the user to predefine several installation variables instead of waiting for them to be prompted. This can be made modifying the preloaded-vars.conf file and uncommenting the configuration lines that you want to automate during the installation process.

Tools (https://documentation.wazuh.com/3.12/user-manual/reference/tools/index.html#tools)

Note sulla configurazione degli Agents
--------------------------------------
Detto questo è utile capire cosa si può modificare dell'agent basandosi anche sulla configurazione che già possiede. Ad esempio ho un client windows a cui sono già state applicate delle policy generiche per windows. Il client è un win 10, esistono altre policy che possono integrare le informazioni? Date un occhiata al contenuto della cartella:
/var/ossec/ruleset/sca/

Il discorso è analogo per un host linux sul quale gira apache o mysql....
Di seguito una panoramica degli oggetti il cui comportamento si può modificare nel modo indicato sopra, c'è il link per osquery. Sulle macchine linux è opportuno installare auditd. Sulle macchine windows può essere necessario modificare delle group policy o il comportamento di fim:
Agents can be configured remotely by using the agent.conf file. The following capabilities can be configured remotely:

- File Integrity monitoring (syscheck) 
 	- https://documentation.wazuh.com/3.12/user-manual/capabilities/file-integrity/index.html
 	- https://documentation.wazuh.com/3.12/user-manual/capabilities/auditing-whodata/who-windows.html
	- https://documentation.wazuh.com/3.12/user-manual/capabilities/auditing-whodata/who-windows-policies.html
 	- https://documentation.wazuh.com/3.12/user-manual/capabilities/auditing-whodata/who-linux.html
- Rootkit detection (rootcheck) 
	- https://documentation.wazuh.com/3.12/user-manual/capabilities/policy-monitoring/rootcheck/index.html
  Since Wazuh v3.9.0, the new SCA module replaces Rootcheck when performing policy monitoring.
  The Rootcheck module depends on the Syscheck daemon and its policies feeds are often outdated.
- Log data collection (localfile) 
	- https://documentation.wazuh.com/3.12/user-manual/capabilities/log-data-collection/
	- https://documentation.wazuh.com/3.12/user-manual/capabilities/log-data-collection/how-to-collect-wlogs.html
	- https://documentation.wazuh.com/3.12/user-manual/capabilities/log-data-collection/how-to-collect-wlogs.html#available-channels-and-providers
   
### Eventchannel for Wazuh >= 3.9.0

````
   Source 	Rule IDs 	Rule file
   Base rules 	60000 - 60099 	0575-win-base_rules.xml
*  Security 	60100 - 60599 	0580-win-security_rules.xml		 - Security
*  Application 	60600 - 61099 	0585-win-application_rules.xml		 - Application
*  System 	61100 - 61599 	0590-win-system_rules.xml		 - System
   Sysmon 	61600 - 62099 	0595-win-sysmon_rules.xml		 - Microsoft-Windows-Sysmon/Operational
   Windows Defender 	62100 - 62599 	0600-win-wdefender_rules.xml	 - Microsoft-Windows-Windows-Defender/Operational
   McAfee 	62600 - 63099 	0605-win-mcafee_rules.xml		 - Application
   Eventlog 	63100 - 63599 	0610-win-ms_logs_rules.xml		 - System
   Microsoft Security Essentials 	63600 - 64099 	0615-win-ms-se_rules.xml - System
   Others 	64100 - 64599 	0620-win-generic_rules.xml
* già presenti nella confgurazione dell'agente per windows
   Other channel
    source		channel location							provider name	description
    Remote Access 	File Replication Service 						Any		Other channels (they are grouped in a generic Windows rule file).
    Terminal Services 	Service Microsoft-Windows-TerminalServices-RemoteConnectionManager
````

CIS-CAT
-------
Security policy monitoring (wodle name=”open-scap”, wodle name=”cis-cat”)
	- https://documentation.wazuh.com/3.12/user-manual/capabilities/policy-monitoring/openscap/index.html#openscap
   security compliance, vulnerability assessments, specialized assessments. The OpenSCAP integration is only available on Linux hosts, not Windows agents.
 	- https://documentation.wazuh.com/3.12/user-manual/capabilities/policy-monitoring/ciscat/ciscat.html#cis-cat-integration
The CIS-CAT tool is proprietary software which requires an external license for its use Remote commands (wodle name=”command”)
	- https://documentation.wazuh.com/3.12/user-manual/capabilities/command-monitoring/index.html#command-monitoring

Labels for agent alerts (labels)
	- https://documentation.wazuh.com/3.12/user-manual/capabilities/labels.html#agent-labels

Security Configuration Assessment (sca) notes
	A check will be marked as not applicable in case an error occurs while performing the check.
    In such cases, instead of including the field result, fields: status and reason will be included.
	- https://documentation.wazuh.com/3.12/user-manual/capabilities/sec-config-assessment/how_to_configure.html#available-sca-policies

````   
/var/ossec/ruleset/sca/
   Policy 			Name 							Requirement
   cis_win2012r2_domainL1 	CIS benchmark for Windows 2012 R2 Domain Controller L1 	Windows Server 2012 R2
   cis_win2012r2_domainL2 	CIS benchmark for Windows 2012 R2 Domain Controller L2 	Windows Server 2012 R2
   cis_win2012r2_memberL1 	CIS benchmark for Windows 2012 R2 Member Server L1 	Windows Server 2012 R2
   cis_win2012r2_memberL2 	CIS benchmark for Windows 2012 R2 Member Server L2 	Windows Server 2012 R2
   cis_win10_enterprise_L1 	CIS benchmark for Windows 10 Enterprise (Release 1709) 	Windows 10
   cis_win10_enterprise_L2 	CIS benchmark for Windows 10 Enterprise (Release 1709) 	Windows 10
   sca_win_audit 		Benchmark for Windows auditing 				Windows
   cis_rhel5_linux 		CIS Benchmark for Red Hat Enterprise Linux 5 		Red Hat Systems
   cis_rhel6_linux 		CIS Benchmark for Red Hat Enterprise Linux 6 		Red Hat Systems
   cis_rhel7_linux 		CIS Benchmark for Red Hat Enterprise Linux 7 		Red Hat Systems
   cis_debian7_L1 		CIS benchmark for Debian/Linux 7 L1 			Debian 7
   cis_debian7_L2 		CIS benchmark for Debian/Linux 7 L2 			Debian 7
   cis_debian8_L1 		CIS benchmark for Debian/Linux 8 L1 			Debian 8
   cis_debian8_L2 		CIS benchmark for Debian/Linux 8 L2 			Debian 8
   cis_debian9_L1 		CIS benchmark for Debian/Linux 9 L1 			Debian 9
   cis_debian9_L2 		CIS benchmark for Debian/Linux 9 L2 			Debian 9
   cis_sles11_linux 		CIS SUSE Linux Enterprise 11 Benchmark 			SUSE 11
   cis_sles12_linux 		CIS SUSE Linux Enterprise 12 Benchmark 			SUSE 12
   cis_solaris11 		CIS benchmark for Oracle Solaris 11 			Solaris 11
   sca_unix_audit 		Benchmark for Linux auditing 				N/A
   cis_apple_macOS_10.11 	CIS Apple OSX 10.11 Benchmark 				MAC OS X 10.11 (El Capitan)
   cis_apple_macOS_10.12 	CIS Apple macOS 10.12 Benchmark 			MAC OS X 10.12 (Sierra)
   cis_apple_macOS_10.13 	CIS Apple macOS 10.13 Benchmark 			MAC OS X 10.13 (High Sierra)
   web_vulnerabilities 		System audit for web-related vulnerabilities 		N/A
   cis_apache_24 		CIS Apache HTTP Server 2.4 Benchmark 			Apache configuration files
   cis_mysql5-6_community 	CIS benchmark for Oracle MySQL Community Server 5.6 	MySQL configuration files
   cis_mysql5-6_enterprise 	CIS benchmark for Oracle MySQL Enterprise 5.6 		MySQL configuration files
````

SCA Policies
------------
	- https://documentation.wazuh.com/3.12/user-manual/capabilities/sec-config-assessment/creating_custom_policies.html#creating-custom-sca-policies

System inventory (syscollector)
-------------------------------
    - https://documentation.wazuh.com/3.12/user-manual/capabilities/syscollector.html?highlight=syscollector
    - https://documentation.wazuh.com/3.12/user-manual/capabilities/syscollector.html?highlight=syscollector#compatibility-matrix
    - https://documentation.wazuh.com/3.12/user-manual/capabilities/vulnerability-detection/running_vu_scan.html#running-a-vulnerability-scan-a|m
    - https://documentation.wazuh.com/3.12/user-manual/capabilities/vulnerability-detection/allow_os.html#scan-vulnerabilities-on-unsupported-systems
    - https://documentation.wazuh.com/3.12/user-manual/reference/ossec-conf/vuln-detector.html

Avoid events flooding (client_buffer)
-------------------------------------
    - https://documentation.wazuh.com/3.12/user-manual/capabilities/antiflooding.html

Configure osquery wodle (wodle name=”osquery”)
----------------------------------------------
    - https://documentation.wazuh.com/3.12/user-manual/capabilities/osquery.html

Retention degli eventi
----------------------

Se wazuh andasse giù, gli agents quanti eventi conserverebbero e per quanto tempo?

- https://documentation.wazuh.com/3.12/user-manual/reference/ossec-conf/client_buffer.html