#!/bin/bash

# example usage:
# bash criptocat_client.sh -h 127.0.0.1 -p 2223 -k 73756b61 -i 6475 -w secret

while getopts h:p:k:i:w: option
do
case "${option}"
in
h) HOST=${OPTARG};;
p) PORT=${OPTARG};;
k) KEY=${OPTARG};;
i) IV=${OPTARG};;
w) WORD=${OPTARG};;
esac
done

echo -n $WORD | openssl enc -aes-256-cbc -e -k $KEY -iv $IV -base64  | nc $HOST $PORT
