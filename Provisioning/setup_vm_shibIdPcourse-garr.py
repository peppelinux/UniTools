from paramiko import client

HOSTS = """idp0;10.45.185.79;debian;thatpasswd0
idp1;10.45.184.36;debian;thatpasswd1
idp2;10.45.184.76;debian;thatpasswd2
idp3;10.45.184.78;debian;thatpasswd3
idp4;10.45.184.20;debian;thatpasswd4
idp5;10.45.184.10;debian;thatpasswd5
idp6;10.45.184.23;debian;thatpasswd6
idp7;10.45.184.37;debian;thatpasswd7
idp8;10.45.184.49;debian;thatpasswd8
idp9;10.45.184.21;debian;thatpasswd9
idp10;10.45.184.51;debian;thatpasswd10
idp11;10.45.184.52;debian;thatpasswd11
idp12;10.45.184.56;debian;thatpasswd12
idp13;10.45.184.92;debian;thatpasswd13
idp14;10.45.184.50;debian;thatpasswd14
idp15;10.45.184.45;debian;thatpasswd15
idp16;10.45.184.25;debian;thatpasswd16
idp17;10.45.184.19;debian;thatpasswd17
idp18;10.45.185.15;debian;thatpasswd18
idp19;10.45.184.31;debian;thatpasswd19
idp20;10.45.184.39;debian;thatpasswd20
idp21;10.45.184.30;debian;thatpasswd21
idp22;10.45.184.43;debian;thatpasswd22
idp23;10.45.184.35;debian;thatpasswd23
idp24;10.45.184.79;debian;thatpasswd24
idp25;10.45.184.41;debian;thatpasswd25
idp26;10.45.184.209;debian;thatpasswd26
idp27;10.45.185.1;debian;thatpasswd27
idp28;10.45.184.239;debian;thatpasswd28
idp29;10.45.184.85;debian;thatpasswd29
idp30;10.45.184.61;debian;thatpasswd30
idp31;10.45.185.46;debian;thatpasswd31
idp32;10.45.184.98;debian;thatpasswd32
idp33;10.45.185.9;debian;thatpasswd33
idp34;10.45.184.65;debian;thatpasswd34
idp35;10.45.185.43;debian;thatpasswd35
idp36;10.45.185.60;debian;thatpasswd36
idp37;10.45.184.148;debian;thatpasswd37
idp38;10.45.185.66;debian;thatpasswd38
idp39;10.45.184.77;debian;thatpasswd39
idp40;10.45.185.44;debian;thatpasswd40""".splitlines()

CMD_TEST = """JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto/jre /opt/shibboleth-idp/bin/aacli.sh -n luigi -r  https://shib-sp.aai-test.garr.it/shibboleth"""

CMDS = """
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/lib/dpkg/lock
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y python3-dev python3-setuptools python3-pip easy-rsa expect-dev git
sudo pip3 install ansible
sudo rm -Rf ansible-slapd-eduperson2016/
git clone https://github.com/ConsortiumGARR/ansible-slapd-eduperson2016.git
cd ansible-slapd-eduperson2016/ && sudo ansible-playbook -i "localhost," -c local playbook.yml
cd ..
sudo sudo apt-get install -y python3-pip python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg-dev zlib1g-dev ldap-utils
rm -Rf Ansible-Shibboleth-IDP-SP-Debian
git clone https://github.com/ConsortiumGARR/Ansible-Shibboleth-IDP-SP-Debian.git
cd Ansible-Shibboleth-IDP-SP-Debian/ && sudo ansible-playbook -i "localhost," -c local playbook.yml
""" + CMD_TEST

def go(ssh_client, cmds, hosts):
    for host in hosts:
        host = host.split(';')
        hostname, url, passw, user = host[0], host[1], host[-1], host[2]
        print("Connecting to {} ({}).".format(url, hostname))
        ssh_client.connect(hostname=url,
                           username=user,
                           password=passw)
        for cmd in cmds.splitlines():
            print("\tExecuting: [{}] to '{}'".format(cmd, hostname))
            stdin, stdout, stderr = ssh_client.exec_command(cmd)
            out = stdout.read()
            if out: print('\t{}'.format(out.decode()))
            err = stderr.read()
            if err:
                print("\tError: {}".format(err.decode()))
        print('\n\n\n')


if __name__ == '__main__':
    TEST = 1

    ssh_client = client.SSHClient()
    ssh_client.load_system_host_keys()
    ssh_client.set_missing_host_key_policy(client.AutoAddPolicy())

    if not TEST:
        go(ssh_client, CMDS, HOSTS)
    else:
        go(ssh_client, CMD_TEST, HOSTS)
