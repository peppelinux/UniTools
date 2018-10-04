Some usefull notes about hashing function with openssl (and more)
----------------------------------------------------------------------

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
