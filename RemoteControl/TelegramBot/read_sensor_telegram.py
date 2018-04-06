#!/usr/bin/env python3

# linux command
# stty -F /dev/ttyACM0 9600

import re
import time
import os, sys

from telegram.ext import Updater

TEMP_MAX=24.0
DEVICE='/dev/ttyACM0'

# Telegram's
# per ottenere un token contatta botfather in chat e scrivi /newbot e /token
TOKEN="NNNN:XXXXXXXXXXXXXXXXXXXXXXY"
# invita il bot nel gruppo e per ottenere la chat_id del gruppo scrivi
# /tuousername @username_bot
# https://api.telegram.org/bot<YourBOTToken>/getUpdates
CHAT_ID="-302071441"

updater = Updater(token=TOKEN)
dispatcher = updater.dispatcher

def ReadSensor():
    """
    read until regex works or max_cnt is reached
    
    example:
    'Current humdity = 35.0%  temperature = 22.0C  \n'
    """
    
    regex = 'Current humdity = (?P<hum>[0-9\.]+)(?P<hum_unit>%)  temperature = (?P<temp>[0-9\.]+)(?P<temp_unit>C)'
    cnt = 0
    max_cnt = 33
    
    f = open(DEVICE)
    r = None
    
    while cnt < max_cnt:
        res = re.search(regex, f.readline())
        if res:
            r = dict(res.groupdict())
            r['temp'] = float(r['temp']) 
            r['hum'] = float(r['hum'])
            print(r)
            break
        time.sleep(0.5)
        cnt += 1
    return r

try:
    os.system('stty -F {} 9600'.format(DEVICE))
    sens = ReadSensor()
except Exception as e:
    dispatcher.bot.send_message(chat_id=CHAT_ID, text='ERRORE I/O sensore temperatura: {}'.format(e))

if not sens:
    dispatcher.bot.send_message(chat_id=CHAT_ID, text='Problema lettura sensore, richiesta verifica accesso al dispositivo. Grave!')

if sens['temp'] < TEMP_MAX:
    sys.exit()

dispatcher.bot.send_message(chat_id=CHAT_ID, text='Temperatura CED superiore al limite, {}°. Umidità relativa: {}%'.format(sens['temp'], sens['hum']))
