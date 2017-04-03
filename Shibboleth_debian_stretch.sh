
# dependencies
aptitude install libmemcached11 libodbc1 shibboleth-sp2-common libshibsp7 libshibsp-plugins shibboleth-sp2-utils

# directory that contains Shibboleth SP configuration files
ls /etc/shibboleth/ 

# directory which contains 'shibauthorizer' and 'shibresponder'. Those are fast-cgi executables required for nginx integration.
ls /usr/lib/x86_64-linux-gnu/shibboleth/

# If one of the above is missing it means that something went wrong and you may double check if those dependencies have been installed correctly.

# install supervisor for fastCGI-Schibboleth secure integration
apt-get install supervisor

# recompile nginx for integrating shib module
https://serversforhackers.com/compiling-third-party-modules-into-nginx
