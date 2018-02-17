#!/bin/bash

# MUL_FACTOR is sized on hours ((x / minutes /) hours)
MUL_FACTOR=0.0002777777777777778

if [ -z "$1" ] || [ -z "$2" ]
  then
        echo "Check ttl renewal of a domain on its soa dns"
        echo "SOA record is a Start of Authority. Every domain must have a Start of Authority record at the cutover point where the domain is delegated from its parent domain"
        echo "Usage: this_command.sh host.domain.to.check soanameserver.domain.to.check"
        exit 1
fi

host -v $1 $2 | grep SOA | head -1 | awk -F' ' {'print $2'}  | awk '{printf "Rinnovo ogni %4.2f ore\n",$0*'$MUL_FACTOR'}'

