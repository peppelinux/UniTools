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

Todo

- Possibilità di generare le CA e chiavi on-the-fly sulla base degli attributi del playbook
- Scelta tra Apache e Nginx/FastCGI come webserver (per sp)
- Scelta tra Tomcat7 e Jetty come contenitore servlet (per idp)
- schema migrations per DB e LDAP
- logrotate setup per le directory di logging

Per utilizzare questo playbook basta installare ansible rigorosamente in ambiente python2

    pip2 install ansible


Comandi di deployment e cleanup
===============================

Creazione delle chiavi firmate:
    
    # installa easy-rsa
    aptitude install easy-rsa
    cp -Rp /usr/share/easy-rsa/ .
    cd easy-rsa

    # personalizziamo attributi, lunghezza DH, percorso di salvataggio delle chiavi
    nano vars

    # activate environment
    source vars

    # purge all the previous keys/dh/crts
    ./clean-all

    # creates: ca.crt	ca.key	index.txt serial
    ./build-ca

    # creates diffie hellman's 
    # il tempo di creazione varia dalla lunghezza del dh, 4096bit prende qualche minuto in più
    ./build-dh

    # then creates client certificates
    ./build-key idp.example.org
    ./build-key sp.example.org

    # adesso nella directory "keys" troviamo le chiavi
    # da spostare in $shibboleth-Idp3-ansible/roles/common/files/$nome_dominio
    # rinominando
    cp keys/ca.crt $shibboleth-Idp3-ansible/roles/common/files/$nome_dominio/cacert.pem
    cp keys/ca.key $shibboleth-Idp3-ansible/roles/common/files/$nome_dominio/cakey.pem
    cp keys/idp.$nome_dominio.crt $shibboleth-Idp3-ansible/roles/common/files/$nome_dominio/$nome_dominio-cert.pem
    cp keys/idp.$nome_dominio.key $shibboleth-Idp3-ansible/roles/common/files/$nome_dominio/$nome_dominio-key.pem    
    cp keys/sp.$nome_dominio.key $shibboleth-Idp3-ansible/roles/common/files/$nome_dominio/$nome_dominio-key.pem
    cp keys/sp.$nome_dominio.crt $shibboleth-Idp3-ansible/roles/common/files/$nome_dominio/$nome_dominio-cert.pem



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

Esegui tutto, equivalente a pre_t:3 di Davide:
    
    ansible-playbook playbook.yml -i hosts -v --limit idp -e '{ cleanup: true }'

Note
========================

Gli utenti creati in slapd sono definiti in
    
    roles/slapd/templates/direcory-content.ldif

E' necessario configurare gli hostname in /etc/hosts o utilizzare un nameserver dedicato per accedere al servizio HTTPS
    
    https://sp.testunical.it

Testato su

    Ubuntu/Trusty 32bit
    Debian Wheezy 7 32bit/64bit (sostituire dipendenza emacs24-nox con emacs23-nox)
