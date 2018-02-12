#!/bin/bash

# tested on Proxmox 4.4
cd /usr/share/pve-manager/ext6/
cp pvemanagerlib.js pvemanagerlib.js.old
sed  "s|if (data\.status !== 'Active') {|if (data\.status == 'Active') {|g" pvemanagerlib.js.old > pvemanagerlib.js

# tested on Proxmox 5.0 and 5.1
cd /usr/share/pve-manager/js/
cp pvemanagerlib.js pvemanagerlib.js.old
sed  "s|if (data\.status !== 'Active') {|if (data\.status == 'Active') {|g" pvemanagerlib.js.old > pvemanagerlib.js
