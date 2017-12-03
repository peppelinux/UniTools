#!/usr/bin/python3

import sys
import ldap3


def search(value):
   for i in ldap3.protocol.rfc4512.Oids.items():
       if var.lower() in str(i).lower():
           print(i)


if __name__ == '__main__':
    search(sys.args[1])
