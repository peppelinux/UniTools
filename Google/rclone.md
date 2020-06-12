## Initial setup
````
apt install rclone

# create an OAuth2 client_id and client_secret
# create google drive called gdrive
rclone config
````
## Main configuration
Create a proper mount service to be recognized by system (eg.: `/etc/systemd/system/rclone-gdrive.service`) and ensure related `rclone` attributes are properly defined (eg.: the name of the remote, `gdrive:`; the local mount point, `/media/gdrive`; the main `rclone` configuration file, `/home/wert/.config/rclone/rclone.conf`)

````
[Unit]
Description=RClone Service
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/rclone mount gdrive: /media/gdrive \
   --config /home/wert/.config/rclone/rclone.conf 
   --allow-other \
   --vfs-read-chunk-size 16M \
   --buffer-size 2G 
ExecStop=/bin/fusermount -uz /media/gdrive
Restart=on-abort
User=
Group=

[Install]
WantedBy=default.target
````
#### Warning
Depending on the usage pattern of your rclone-driven fuse storage, you might encounter some problems. For example, if you plan to use it as a storage-backend for your backup solution, then you could need to configure a proper `--vfs-cache-mode`. In detail, above further options could be useful:

````
   --vfs-cache-mode writes
   --allow-non-empty \
   --acd-templink-threshold 0 \
   --checkers 32 \
   --log-level INFO \
   --log-file /tmp/mount-garr.log \
   --max-read-ahead 2G \
````

## Other info
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

## Errors on start
if ``--allow-other`` flag is set remember to add/enable ``user_allow_other`` in in /etc/fuse.conf file.
