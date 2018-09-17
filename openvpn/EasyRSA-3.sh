easyrsa init-pki
easyrsa build-ca
easyrsa gen-dh

# vpn server
easyrsa gen-req server nopass

# user client 
easyrsa gen-req peppelinux nopass

# copy/import request to CA if they was created to different machines
# ./easyrsa import-req /path/to/received.req UNIQUE_SHORT_FILE_NAME

# check cert request for example
easyrsa show-req server

# cert client
# put your CA passphrase
easyrsa sign-req client peppelinux 

# cert server
easyrsa sign-req server server

# structure:
pki/private/ -> keys
pki/issued/ -> crt
pki/reqs -> signing requests
