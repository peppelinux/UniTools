Is your server secure?

Log onto your server via SSH as the root user and enter the following command replacing serverip with the IP of your server.
If the command returns a long list of IP addresses then your server is vulnerable!

````
ntpdc -n -c monlis serverip
````

