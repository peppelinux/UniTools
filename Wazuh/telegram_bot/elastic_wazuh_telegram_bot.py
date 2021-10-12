#!/usr/bin/env python3

import datetime
import json
import re
import requests
import time

from elasticsearch import Elasticsearch

"""
pip3 install elasticsearch requests

echo "
[Unit]
Description=elwazu-bot

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/elwazuh.py

[Install]
WantedBy=multi-user.target
" > /lib/systemd/system/elwazu.service

systemctl daemon-reload
systemctl enable elwazu.service
"""


TELEGRAM_TOKEN  = 'XXXXXXXXXXXXXXXXXXXXXXXXXX'
TELEGRAM_CHATID = 'XXXXXXXXXXXX'
TELEGRAM_URL = ('https://api.telegram.org/bot'
                '{}'
                '/sendMessage?chat_id='
                '{}'
                '&text=').format(TELEGRAM_TOKEN,
                                 TELEGRAM_CHATID)

#DATETIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%f%z"
_TIMEOUT_SECONDS = 10

EL_HOST = '172.16.16.253'
EL_PORT = 9200
EL_SERVER = "http://{}:{}".format(EL_HOST, EL_PORT)
EL_SEARCH_PATH = "{}/_search?pretty".format(EL_SERVER)

EL_SEARCH_HEADERS = 'Content-Type: application/json'
EL_INDEX = 'wazuh-alerts-3.x-*' #{}'.format(datetime.date.today().strftime('%Y.%m.%d'))
EL_SEARCH_QUERY_LIMIT = 10000
EL_SEARCH_QUERY_COLUMNS = ['rule.id',
                           'rule.description',
                           'rule.level',
                           'rule.groups',
                           'rule.firedtimes',
                           'agent',
                           'localtion',
                           'full_log',
                           'timestamp']

_UNDESIDERED_RULE_ID = (
                        "533", # netstat port change
                        "5710", # sshd: Attempt to login using a non-existent user
                        )

# SIMPLE QUERY 
#EL_SEARCH_QUERY = { "query" :
                    #{ "query_string" : { "query" : "rule.level:>3"},
                    #}
                  #}

# THAT QUERY
EL_SEARCH_QUERY = {
                      "query": {
                        "bool": {
                          "must": [
                            {
                              "range": {
                                "rule.level": {"gte": 3, "lte": 20}
                              }
                            },
                            ],
                            "must_not" : [
                            {
                              "match": {
                                "rule.groups": "osquery"
                              }
                            }],
                            #{
                              #"match": {
                                #"rule.level": 3
                              #}
                            #}
                          "filter": [
                            {
                              "range" : {
                                "timestamp" : {
                                    "gt" : "now-{}s".format(_TIMEOUT_SECONDS),
                                    "lt" :  "now" # "lte": "2018-08-15T23:00:00Z"
                                    }
                                }
                            }
                          ]
                        }
                      }
                    }


def el_query(es, index = EL_INDEX, query = EL_SEARCH_QUERY,
                 columns = EL_SEARCH_QUERY_COLUMNS):
    res = es.search(index = index, body = query,
                    size = EL_SEARCH_QUERY_LIMIT,
                    _source_includes=columns)
    things = res['hits']['hits']
    result = [things[i]['_source'] for i in range(len(things))]
    return result


def telegram_pub(json_dict):
     msg = ('   [WAZUH][SIEM]   \n'
            'We had {} events in the last {} seconds:\n\n').format(len(json_dict),
                                                                   _TIMEOUT_SECONDS)
     url = TELEGRAM_URL + msg + json.dumps(json_dict, indent=2)
     requests.get(url)


def remove_duplicates(res):
    # remove duplicated
    regexps = [r'nvalid (user )?(?P<user>[a-zA-Z0-9_-]*) (from )?(?P<host>[0-9]+.[0-9]+.[0-9]+.[0-9]+)',
               r'Accepted publickey for (?P<user>[a-zA-Z0-9_-]*) (from )?(?P<host>[0-9]+.[0-9]+.[0-9]+.[0-9]+)',
               '(?P<host>[a-zA-Z0-9_-]*) sshd\[[0-9]+\]: pam_unix\(sshd:session\): session (opened)|(closed) for user (?P<user>[a-zA-Z0-9_-]*)']
    dups = []
    new_res = []
    for i in res:
        check = None
        for regexp in regexps:
            check = re.findall(regexp, i.get('full_log', ''))
            if check and check not in dups:
                dups.append(check)
                new_res.append(i)
                break
            elif check and check in dups:
                break
        if not check:
            new_res.append(i)
    return new_res


def remove_undesidered(res):
    new_res = []
    for i in res:
        if i['rule']['id'] not in _UNDESIDERED_RULE_ID:
            new_res.append(i)
    return new_res


def run(es):
    res = el_query(es)
    if not res: return
    #print(json.dumps(res, indent=2))
    res2 = remove_duplicates(res)
    res3 = remove_undesidered(res2)
    if res3:
        print(json.dumps(res3, indent=2))
        telegram_pub(res3)



if __name__ == '__main__':
    es = Elasticsearch([{'host': EL_HOST, 'port': EL_PORT}])
    while 1:
        time.sleep(_TIMEOUT_SECONDS)
        run(es)
         
