#!/user/bin/env python3
"""
Simple Script that send Wazuh Alerts with level >= 6 to Telegram Channel
@Author: Francesco Izzi @ CNR IMAA
"""

# Imports
import subprocess
import json
import requests

bot_token = 'XXXXXXXXXXXX'
bot_chatID = 'XXXXXXXXXXX'

f = subprocess.Popen(['tail','-F',"alerts.json"],\
        stdout=subprocess.PIPE,stderr=subprocess.PIPE)

def main():
    while True:
	    line = f.stdout.readline()
	    parsed_json = (json.loads(line))
	    
	    if(parsed_json['rule']['level']>=6):
	      send_text = 'https://api.telegram.org/bot' + bot_token + '/sendMessage?chat_id=' + bot_chatID + '&text= [SIEM WAZUH] ' + str(parsed_json)
	      response = requests.get(send_text)
	      print(response.json())

# Main body
if __name__ == '__main__':
    main()