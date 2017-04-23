Shibboleth Ansible provisioning
===============================


Playbok Ansible per installare e configurare un setup classico di 

- tomcat7
- apache2
- mod_shib2
- mysql
- slapd
- ShibbolethIdp
- ShibbolethSP

Ispirato da Garr Netvolution 2017 (http://eventi.garr.it/it/ws17) e basato sul lavoro di Davide Vaghetti:

https://github.com/daserzw/IdP3-ansible

Funzionalità:

- Possibilità di configurare il dominio (non più soltanto example.org)
- Variabili personalizzabili, template, configurazione dinamizzata

Per utilizzare questo playbook basta installare ansible rigorosamente in ambiente python2
pip2 install ansible


Comandi di deployment e cleanup
===============================

Esecuzione del setup comune a tutti
    
    ansible-playbook playbook.yml -i hosts --tag common

Esecuzione selettiva, quei roles limitati ai nodi idp
    
    ansible-playbook playbook.yml -i hosts -v --tag tomcat7,slapd --limit idp
    
Esecuzione selettiva, quei roles limitati a quel target

    ansible-playbook playbook.yml -i hosts -v --tag tomcat7,slapd --extra-vars "target=idp"

Purge e reinstall di tomcat7

    ansible-playbook playbook.yml -i hosts -v --tag tomcat7 --limit idp -e '{ cleanup: true }'

Setup di Shibboleth Idp3
    
    ansible-playbook playbook.yml -i hosts -v --tag shib3idp --limit idp 

Setup di apache2 e mod_shib per configurazione Idp3 e Service Provider generico
    
    ansible-playbook playbook.yml -i hosts -v --tag apache2
