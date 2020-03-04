apt install rclone

# create an OAuth2 client_id and client_secret
# create google drive called gdrive
rclone config

mkdir -p /media/gdrive

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
Options=auto,allow-other,default-permissions,read-only,max-read-ahead=16M
TimeoutSec=30

[Install]
WantedBy=multi-user.target
````

# if problems during umount
fusermount -u /media/gdrive 

# copy things manually
rclone copy /opt/dumps_adas/ gdrive:/ICT_backups/adas.unical.it


