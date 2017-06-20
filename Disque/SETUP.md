```bash

#!/bin/bash

set -e
set -x

aptitude install build-essential git tcl
cd /tmp
git clone https://github.com/antirez/disque.git
cd disque/
make
make test
sudo make install
mkdir /etc/disque/
cp disque.conf /etc/disque/
nano /etc/disque/disque.conf   # configure daemonize, pidfile, bind

/bin/mkdir -p /opt/disque/
/bin/mkdir -p /opt/disque
sudo useradd -M -r disque
/bin/chown -R disque:disque /opt/disque/ /opt/disque

# Creates a systemd target
echo "
[Unit]
Description=Disque Distributed Message Broker
After=network.target

[Service]
Type=forking
WorkingDirectory=/opt/disque
PermissionsStartOnly=true
#Environment=statedir=/opt/disque
PIDFile=/opt/disque/disque.pid
User=disque
Group=disque
ExecStart=/usr/local/bin/disque-server /etc/disque/disque.conf
ExecReload=/bin/kill -USR2
ExecStop=/usr/local/bin/disque shutdown
Restart=always

[Install]
WantedBy=multi-user.target
" > /tmp/disque.service

echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
# avoids # WARNING: overcommit_memory is set to 0! Background save may fail under low memory condition.
sysctl -w vm.overcommit_memory=1

# avoids #  WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
sysctl -w net.core.somaxconn=65535

#
cp /tmp/disque.service /etc/systemd/system/disque.service
sudo systemctl daemon-reload # reload systemd
sudo service disque start    # actually start the service
sudo service disque status   # ensure everything is running well
```
