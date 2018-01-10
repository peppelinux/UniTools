# Tested on Debian9
# Taken from: https://github.com/astrada/google-drive-ocamlfuse/wiki/Installation

SYS_USER="peppe"
MOUNT_POINT="/media/gdrive"

sudo apt-get install opam ocaml make fuse camlp4-extra build-essential pkg-config
sudo groupadd fuse
sudo adduser $SYS_USER fuse
# now logout and then login again

opam init
eval `opam config env`
opam update
opam install depext
opam depext google-drive-ocamlfuse
opam install google-drive-ocamlfuse
. /home/$SYS_USER/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

# configure autorization
# create an oauth2 IDclient and secret
google-drive-ocamlfuse -id  $VALUE.apps.googleusercontent.com  -secret  $YOUR_SECRET  -headless
# auth with the returning url, give the autorizations to the app and then copy the verification code to the ocalm prompt, then
# Access token retrieved correctly.

# auto mount on boot
# create this specialized script:
echo '
#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
MOUNTPOINT="/media/gdrive"
export SYS_USER="peppe"
export LABEL="google-drive"
su $SYS_USER -l -c "source /home/$SYS_USER/.opam/opam-init/init.sh && google-drive-ocamlfuse $MOUNTPOINT"
exit 0' > /usr/sbin/gdfuse

chmod 775 /usr/sbin/gdfuse

# create mount point
mkdir /media/gdrive
chown -R $SYS_USER $MOUNT_POINT

# mount it
google-drive-ocamlfuse $MOUNT_POINT

# put this definition in fstab, the UID value must be the $SYS_USER uid!
gdfuse#default /media/gdrive fuse uid=1000,gid=1000,user 0 0

# if some other profile should be also mounted
# gdfuse#account_peppe_2  /home/$SYS_USER/gdrive2     fuse    uid=1000,gid=1000     0       0


