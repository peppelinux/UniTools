
aptitude install bridge-utils

# the in server.conf comment
# dev-type tun
# server x.y.z.e

#and replace with
dev-type tap
server-bridge 10.97.59.2 255.255.255.0 10.97.59.128 10.97.59.254

