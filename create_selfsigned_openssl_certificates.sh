#~ An SSL certificate can easily be generated on your machine 
#~ using OpenSSL. Before you can create one you must create a SSL Certificate 
#~ of Authority. Then with your CA you can generate a certificate request 
#~ and then the certificate following the steps below.

export CN="test.unical.it"
export CERTS_DIR='/etc/ssl/certs'

# Step 1: Generate a Private Key
openssl genrsa -out server.key 4096

# Step 2: Generate a CSR (Certificate Signing Request)
openssl req -new -nodes -sha256 -key server.key -out server.csr -subj "/C=IT/ST=Italy/L=Arcavacata/O=University of Calabria/OU=Unical/CN=$CN"

# Step 2.5: Remove Passphrase from Key
#~ cp server.key server.key.orig
#~ openssl rsa -in server.key.org -out server.key

# Step 3: Generating a Self-Signed Certificate
openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt

# Step 4: Installing the Private Key and Certificate
cp server.crt $CERTS_DIR/ssl.crt
cp server.key $CERTS_DIR/ssl.key
