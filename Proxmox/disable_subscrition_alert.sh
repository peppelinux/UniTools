#!/bin/bash

cd /usr/share/pve-manager/ext6/
cp pvemanagerlib.js pvemanagerlib.js.old
sed  "s|(data\.status !== 'Active')|(data\.status == 'Active')|g" pvemanagerlib.js.old > pvemanagerlib.js
