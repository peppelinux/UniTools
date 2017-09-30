#!/bin/bash

LETSENCID="0000"
DOMAIN="test.example.org"

cp /etc/letsencrypt/archive/$DOMAIN/privkey1.pem privkey.pem
cp /etc/letsencrypt/archive/$DOMAIN/cert1.pem cert.pem

openssl req -in csr/$LETSENCID_csr-certbot.pem -noout -pubkey > pubkey
#OR
openssl rsa -in keys/$LETSENCID_key-certbot.pem -pubout > pubkey

echo 'Sono un text in chiaro.' | openssl rsautl -encrypt -pubin -inkey pubkey |  openssl rsautl -decrypt -inkey privkey.pem 

echo "cose scritte" > file.txt
openssl rsautl -encrypt -inkey pubkey -pubin -in file.txt -out file.enc
openssl rsautl -decrypt -inkey privkey.pem -in file.enc -out file.clear.txt
