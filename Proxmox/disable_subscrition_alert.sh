#!/bin/bash

# tested on Proxmox 4.4

cd /usr/share/pve-manager/ext6/
cp pvemanagerlib.js pvemanagerlib.js.old
sed  "s|if (data\.status !== 'Active') {|if (data\.status == 'Active') {|g" pvemanagerlib.js.old > pvemanagerlib.js

cd /usr/share/pve-manager/js/
cp pvemanagerlib.js pvemanagerlib.js.old
sed  "s|if (data\.status !== 'Active') {|if (data\.status == 'Active') {|g" pvemanagerlib.js.old > pvemanagerlib.js
