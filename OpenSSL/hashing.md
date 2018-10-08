Some usefull notes about hashing function with openssl (and more)
----------------------------------------------------------------------

Usefull resources:
 - https://wiki.openssl.org/index.php/Command_Line_Utilities

Note: append `awk -F'= ' {'print $2'}` in a trailing pipe to filter out the hash without line header.

MD5
---

What's this.
How it works.

example filename
````
openssl md5 filename
````

example string
````
echo -n 'secretword' | openssl md5 
````

SHA1
---

What's this.
How it works.

example:
````
openssl sha1 filename
echo -n 'secretword' | openssl sha1
````

RC4
---

````
echo -n 'secretword' | openssl rc4 -K 73756b61  | base64 
````

DES
---

What's this.
How it works.

example:
````
openssl des -in Scaricati/README.md -out Scaricati/README.md.des
echo -n 'secretword' | openssl des | base64 

# des-ecb with inline Key (iv not needed)
echo -n 'secretword' | openssl des-ecb -K 73756b61 | base64

# des-cbc with IV
echo -n 'secretword' | openssl des-cbc -K 73756b61 -iv 6475 | base64 

# Triple-des
echo -n 'secretword' | openssl des3 -K 73756b61 -iv 6475 | base64 
````

AES
---
See also [here](https://github.com/peppelinux/UniTools/blob/master/OpenSSL/AES-CBC-encrypt_file.sh)
````
echo -n 'secretword' | openssl aes-256-cbc -K 73756b61 -iv 6475 | base64 
````

