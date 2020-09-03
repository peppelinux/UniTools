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
