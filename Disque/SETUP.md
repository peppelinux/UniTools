cd /tmp
git clone https://github.com/antirez/disque.git
cd disque/
make
make test
sudo make install
sudo useradd -M -r disque
mkdir /etc/disque/
cp disque.conf /etc/disque/
nano /etc/disque/disque.conf   # configure daemonize, pidfile, bind

# Creates a systemd target
echo <<< EOL
[Unit]
Description=Disque Distributed Message Broker
After=network.target

[Service]
Type=forking
PIDFile=/var/run/disque/disque.pid
User=disque
Group=disque

Environment=statedir=/var/run/disque/
WorkingDirectory=/var/run/disque/
PermissionsStartOnly=true
ExecStartPre=/bin/mkdir -p ${statedir}
ExecStartPre=/bin/mkdir -p /var/logs/disque
ExecStartPre=/bin/chown -R disque:disque ${statedir} /var/logs/disque
ExecStart=/usr/local/bin/disque-server /etc/disque/disque.conf
ExecReload=/bin/kill -USR2 $MAINPID
ExecStop=/usr/local/bin/disque shutdown
Restart=always

[Install]
WantedBy=multi-user.target
EOL >> /tmp/disque.service;

#
cp /tmp/disque.services /etc/systemd/system/disque.service
sudo systemctl daemon-reload # reload systemd
sudo service disque start    # actually start the service
sudo service disque status   # ensure everything is running well
