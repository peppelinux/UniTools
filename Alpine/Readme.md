
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
Enable vlan support `apk add vlan`

```
apk add python2-dev curl libressl-dev curl-dev libcurl libjpeg-turbo-dev ca-certificates motion ffmpeg v4l-utils

# install pip
apk add py2-setuptools
easy_install-2.7 pip
# or
curl https://bootstrap.pypa.io/get-pip.py --output get-pip.py
sudo python2 get-pip.py

# check python version
pip --version

pip install git+https://github.com/ccrisan/motioneye.git


```
