# Disaster recovery img from openstack

# copy the image as a reckless
cp /var/lib/nova/instances/_base/dce75bf308c5d08061c3268388472b560/disk .

qemu-img info disk
# image: disk
# file format: qcow2
# virtual size: 80G (85899345920 bytes)
# disk size: 14G
# cluster_size: 65536
# backing file: /var/lib/nova/instances/_base/dce75bf308c5d08061c3268388472b56086a27e1
# Format specific information:
    # compat: 1.1
    # lazy refcounts: false
    # refcount bits: 16
    # corrupt: false

# backing_files chains
qemu-img info --backing-chain disk
# qemu-img: Could not open '/var/lib/nova/instances/_base/dce75bf308c5d08061c3268388472b56086a27e1': Could not read image for determining its format: Is a directory


###########################
# rebase a qcow image
qemu-img rebase -f qcow2 -u -b ./backing disk

# mount con qemu-nbd
qemu-nbd --connect=/dev/nbd0 disk

#####################################
# attach Vbox image as physical disk
VBoxManage internalcommands createrawvmdk -filename ./physical.vmdk -rawdisk /dev/nbd0

#########################
# Seguono comandi utili di cultura generale

# optionals
# apt install nbd-server
# apt install nbd-client

apt install qemu-utils
modprobe nbd max_part=8

#########################
# Gathering informations
file disk
# disk: QEMU QCOW Image (v3), has backing file (path /var/lib/nova/instances/_base/dce75bf308c5d08061c3268388472b560), 85899345920 bytes

###########################
# guestmount
guestmount -a ./disk -m /dev/angelo_disk /mnt

###################################################
# mount qcow2 image
apt install libguestfs-tools

guestmount -a ./disk -m /dev/angelo_disk /mnt


######################################
# image conversion

qemu-img convert ./disk disk.raw
