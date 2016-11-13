#!/bin/bash

# tested on Proxmox 4.x

cd /usr/share/pve-manager/ext6/
cp pvemanagerlib.js pvemanagerlib.js.old
sed  "s|if (data\.status !== 'Active') {|if (data\.status == 'Active') {|g" pvemanagerlib.js.old > pvemanagerlib.js
