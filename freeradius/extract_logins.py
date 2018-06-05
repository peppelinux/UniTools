# PREPROCESSING
# estraggo solo i LOGIN
# zgrep "Login OK" radius_folder_42/radius.log.*  >> ../radius.logins.42.log
# zgrep "Login OK" radius_folder_43/radius.log.*  >> ../radius.logins.43.log

# unisco i risultati
# cat radius.logins.42.log radius.logins.43.log > radius.logins.unified.log
import re
import datetime

_regexp_dt = '([a-z]{3} [a-z]{3} [0-9 ]{1,2} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2} [0-9]{4})'
_regexp_login = r'\[([a-z 0-9\ \.\-\_\:\@\$\+\=\!\?\,\&\#\/\t]*)\]'
_regexp_client = r'\(from client ([a-z0-9\-\_\.]*) '
_regexp_macaddr = r'([0-9a-z]{2}[-:]*[0-9a-z]{2}[-:]*[0-9a-z]{2}[-:]*[0-9a-z]{2}[-:]*[0-9a-z]{2}[-:]*[0-9a-z]{2})'

STRPTIME_FORMAT = '%a %b %d %H:%M:%S %Y'

# it's global... I needed it in a hurry
distinct_logins = []

def extract(fpath, parse_datetime=False, debug=False):
    lista_logins = []
    f = open(fpath)
    
    _dt = re.compile(_regexp_dt, re.I)
    _login = re.compile(_regexp_login, re.I)
    _client = re.compile(_regexp_client, re.I)
    _macaddr = re.compile(_regexp_macaddr, re.I)
    if debug > 0: cnt = 1
    while 1:
        line = f.readline()
        if not line: break
        # try:
        d = {
            'datetime': re.findall(_dt, line),
            'login': re.findall(_login, line),
            'client': re.findall(_client, line),
            'macaddr': re.findall(_macaddr, line),
            }
        # except Exception as e:
            # print('Error {} on: "{}"\n'.format(e, line))
            # continue
        if parse_datetime and d['datetime']:
            d['datetime'] = datetime.datetime.strptime(d['datetime'][0], STRPTIME_FORMAT)
        lista_logins.append(d)
        if d['login'][0] not in distinct_logins:
            distinct_logins.append(d['login'][0])
        if debug > 0:
            cnt += 1
            print(cnt)
        if debug > 1:
            print(d)
        
    f.close()
    return lista_logins


result = extract(fpath='radius.logins.unified.log', parse_datetime=True)
