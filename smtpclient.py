#!/usr/bin/env python3

"""

"""

__version__ = "1.0"
__author__ = "Giuseppe De Marco (giuseppe.demarco@unical.it)"
__copyright__ = "(C) 2018 Giuseppe De Marco. GNU GPL 2."

import argparse
import smtplib
import sys

from time import strftime

usage = "Usage: %prog [options] -from fromaddress -to toaddress -host serveraddress -p 587 -usetls -s \"your subject\" -body \"body message\""
parser = argparse.ArgumentParser(description=usage)
parser.add_argument('-from', dest='fromaddr', required=True, 
                    help="fromaddress")
parser.add_argument('-to', required=True, 
                    help="toaddress")
parser.add_argument('-host', required=True, 
                    help="server addr")
parser.add_argument('-s', required=True, 
                    help="subject")
parser.add_argument('-body', required=True, 
                    help="msg body")
                    
parser.add_argument("-usetls", action="store_true", default=False, help="Connect using TLS, default is false")
parser.add_argument("-usessl", action="store_true", default=False, help="Connect using SSL, default is false")
parser.add_argument("-port", type=int, default=25, help="SMTP server port")
parser.add_argument("-username", type=str, help="SMTP server auth username")
parser.add_argument("-password", type=str, help="SMTP server auth password")
parser.add_argument("-debug", type=int, default=0, help="Set to 1 to print smtplib.send messages")
args = parser.parse_args()

fromaddr = args.fromaddr
toaddr = args.to
serveraddr = args.host
serverport = args.port
    
now = strftime("%Y-%m-%d %H:%M:%S")
msg = "From: {}\r\nTo: {}\r\nSubject: {} {}\r\n\r\n{}\nsent at {}".format(fromaddr, toaddr, args.s, now, args.body, now)

if args.debug:
	print('usetls:', args.usetls)
	print('usessl:', args.usessl)
	print('from address:', fromaddr)
	print('to address:', toaddr)
	print('server address:', serveraddr)
	print('server port:', args.port)
	print('smtp username:', args.username)
	print('smtp password: *****')
	print('subject:', args.s)
	print("-- Message body ---------------------")
	print(msg)
	print("-------------------------------------")

server = None
if args.usessl:
	server = smtplib.SMTP_SSL()
else:
	server = smtplib.SMTP()

server.set_debuglevel(args.debug)
server.connect(serveraddr, serverport)
server.ehlo()
if args.usetls: server.starttls()
server.ehlo()
if args.username: server.login(args.username, args.password)
server.sendmail(fromaddr, toaddr, msg)
server.quit()
