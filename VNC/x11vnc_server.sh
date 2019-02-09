#!/bin/bash

set -x

USER=cla
USER_PATH=/home/$USER/.vnc

X11VNC_CMD="/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth $USER_PATH/passwd -rfbport 5900 -shared"

LEGACY_CONF=$(cat <<EOF
# description "Start x11vnc at boot"

description "x11vnc"

start on runlevel [2345]
stop on runlevel [^2345]

console log

respawn
respawn limit 20 5

exec $X11VNC_CMD
EOF
)


SYSTEMD_CONF=$(cat <<EOF
[Unit]
Description=Start x11vnc at startup.
After=multi-user.target

[Service]
Type=simple
ExecStart=$X11VNC_CMD

[Install]
WantedBy=multi-user.target
EOF
)

echo "$LEGACY_CONF" > /etc/init/x11vnc.conf
echo "$SYSTEMD_CONF" > /etc/systemd/system/x11vnc.service

mkdir -p $USER_PATH
x11vnc -storepasswd $USER_PATH/passwd

sudo chmod u+x /etc/systemd/system/x11vnc.service
sudo systemctl daemon-reload
sudo systemctl enable x11vnc.service
