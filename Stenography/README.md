Steghide example
----------------
Usable only with JPEG files.

````
sudo apt install steghide

# use a secret here
steghide embed -cf tesla.jpg -ef text_to_include.txt 

# then use the same secret
steghide extract -sf tesla.jpg
````
