````
apt install rclone

# create an OAuth2 client_id and client_secret
# create google drive called gdrive
rclone config
````

Create a mount service in systemd called `rclone-gdrive.service`
````
[Unit]
Description=RClone Service
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/rclone mount --config /home/wert/.config/rclone/rclone.conf --allow-other --vfs-read-chunk-size 16M --buffer-size 2G gdrive: /media/gdrive
ExecStop=/bin/fusermount -uz /media/gdrive
Restart=on-abort
User=
Group=

[Install]
WantedBy=default.target
````

Exec on start
````
systemctl daemon-reload
systemctl start rclone-gdrive.service
systemctl enable rclone-gdrive.service
````

````
# if problems during umount
fusermount -u /media/gdrive 

# copy things manually
rclone copy /opt/dumps_adas/ gdrive:/ICT_backups/adas.unical.it
````

