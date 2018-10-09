#!/bin/bash

# example usage:
# bash criptocat_server.sh -p 2223 -k 73756b61 -i 6475

while getopts h:p:k:i:w: option
do
case "${option}"
in
p) PORT=${OPTARG};;
k) KEY=${OPTARG};;
i) IV=${OPTARG};;
esac
done

nc -l -p $PORT | openssl enc -aes-256-cbc  -d -k $KEY -iv $IV -base64
