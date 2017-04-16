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

# using easy-rsa

aptitude install easy-rsa
cp -Rp /usr/share/easy-rsa/ .
cd easy-rsa
nano vars
source vars
./clean-all
./build-ca
./build-dh
./build-key idp.example.org
./build-key sp.example.org
ls keys/

# https://serverfault.com/questions/9708/what-is-a-pem-file-and-how-does-it-differ-from-other-openssl-generated-key-file

# .csr This is a Certificate Signing Request. Some applications can generate 
# these for submission to certificate-authorities. The actual format is PKCS10 
# which is defined in RFC 2986. It includes some/all of the key details of the 
# requested certificate such as subject, organization, state, whatnot, as well 
# as the public key of the certificate to get signed. These get signed by the 
# CA and a certificate is returned. The returned certificate is the public certificate 
# (which includes the public key but not the private key), which itself can be in a 
# couple of formats.

# .pem Defined in RFC's 1421 through 1424, this is a container format that 
# may include just the public certificate (such as with Apache installs, and 
# CA certificate files /etc/ssl/certs), or may include an entire certificate 
# chain including public key, private key, and root certificates. Confusingly, it 
# may also encode a CSR (e.g. as used here) as the PKCS10 format can be translated 
# into PEM. The name is from Privacy Enhanced Mail (PEM), a failed method for 
# secure email but the container format it used lives on, and is a base64 
# translation of the x509 ASN.1 keys.

# .key This is a PEM formatted file containing just the private-key of a 
# specific certificate and is merely a conventional name and not a standardized 
# one. In Apache installs, this frequently resides in /etc/ssl/private. The 
# rights on these files are very important, and some programs will refuse 
# to load these certificates if they are set wrong.

# .pkcs12 .pfx .p12 Originally defined by RSA in the Public-Key Cryptography 
# Standards, the "12" variant was enhanced by Microsoft. This is a passworded 
# container format that contains both public and private certificate pairs.
 # Unlike .pem files, this container is fully encrypted. Openssl can turn this 
 # into a .pem file with both public and private keys: openssl pkcs12 -in 
 # file-to-convert.p12 -out converted-file.pem -nodes
 
# A few other formats that show up from time to time:
# 
# .der A way to encode ASN.1 syntax in binary, a .pem file is just a 
# Base64 encoded .der file. OpenSSL can convert these to .pem (openssl 
# x509 -inform der -in to-convert.der -out converted.pem). Windows sees 
# these as Certificate files. By default, Windows will export certificates 
# as .DER formatted files with a different extension. Like...

# .cert .cer .crt A .pem (or rarely .der) formatted file with a different 
# extension, one that is recognized by Windows Explorer as a certificate, 
# which .pem is not.

# .p7b Defined in RFC 2315, this is a format used by windows for certificate 
# interchange. Java understands these natively. Unlike .pem style certificates, this 
# format has a defined way to include certification-path certificates.

# .crl A certificate revocation list. Certificate Authorities produce these 
# as a way to de-authorize certificates before expiration. You can sometimes 
# download them from CA websites.

