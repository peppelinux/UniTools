
Docker
------
````
docker pull alpine
docker run -it alpine /bin/sh

# create a stateful container
docker container run -it alpine /bin/sh

apk update
apk add python3 python3-dev py3-pip

exit

docker container ls -al
# this saves changes in rootfs
docker commit $container_id
````

netdiscover compilation
-----------------------

````
# add community
vi /etc/apk/repositories

apk update
apk add nmap nano git 

git clone https://github.com/alexxy/netdiscover.git
cd netdiscover
sh update-oui-database.sh

apk add libpcap libcap-dev cmake build-base gcc abuild binutils gcc libnet

cmake .
make
make install
````

motioneye
---------
Enable testing repository and `apk upgrade`

```
apk add python2-dev curl libressl-dev curl-dev libcurl libjpeg-turbo-dev ca-certificates
apk add py2-setuptools
easy_install-2.7 pip

pip install git+https://github.com/ccrisan/motioneye.git


```
