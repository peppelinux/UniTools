 TAP benefits:

    behaves like a real network adapter (except it is a virtual network adapter)
    can transport any network protocols (IPv4, IPv6, Netalk, IPX, etc, etc)
    Works in layer 2, meaning Ethernet frames are passed over the VPN tunnel
    Can be used in bridges 

TAP drawbacks

    causes much more broadcast overhead on the VPN tunnel
    adds the overhead of Ethernet headers on all packets transported over the VPN tunnel
    scales poorly
    can not be used with Android or iOS devices 

TUN benefits:

    A lower traffic overhead, transports only traffic which is destined for the VPN client
    Transports only layer 3 IP packets 

TUN drawbacks:

    Broadcast traffic is not normally transported
    Can only transport IPv4 (OpenVPN 2.3 adds IPv6)
    Cannot be used in bridges 
