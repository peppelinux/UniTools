#!/bin/bash
output=$(slappasswd -h {SSHA} -s password)
hashsalt=$( echo -n $output | sed 's/{SSHA}//' | base64 -d)
salt=${hashsalt:(-1),(-4)}
echo $output
echo $(echo -n $hashsalt | od -A n -t x1)
echo "Salt: $salt"
