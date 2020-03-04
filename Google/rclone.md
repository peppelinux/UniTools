````
apt install rclone

# create an OAuth2 client_id and client_secret
# create google drive called gdrive
rclone config
mkdir -p /media/gdrive
````

Create in `/etc/systemd/system/rclone-automount.mount`
````
[Unit]
Description=rclone mount gdrive: /media/gdrive
Requires=systemd-networkd.service
Wants=network-online.target
After=network-online.target

[Mount]
What=rclonefs#remote:/
Where=/media/gdrive
Type=fuse
Options=auto,config=/home/wert/.config/rclone/rclone.conf,allow-other,default-permissions,max-read-ahead=16M
TimeoutSec=30

[Install]
WantedBy=multi-user.target
````

````
# make it executable
chmod 664 /etc/systemd/system/rclone-automount.service 
systemctl daemon-reload
systemctl start rclone-automount.service 
````

````
# if problems during umount
fusermount -u /media/gdrive 

# copy things manually
rclone copy /opt/dumps_adas/ gdrive:/ICT_backups/adas.unical.it
````

