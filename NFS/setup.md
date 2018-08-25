# on server
````
apt install nfs-kernel-server

# in /etc/exports
/media/1TB_usb 192.168.8.250(rw,no_root_squash,no_subtree_check)

# reload
exportfs -a

# restart NFS
systemctl restart nfs-kernel-server
````

# on client
````
apt install nfs-common

# check nfs server mounts
showmount -e 192.168.13.250

mkdir /media/1TB_usb

# in /etc/fstab
192.168.13.250:/media/1TB_usb /media/1TB_usb nfs4 _netdev,bg,nofail,rw,relatime,rsize=65536,wsize=65536 0 0

mount -a
df -h
````
