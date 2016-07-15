import json
import re
import urllib2
import BeautifulSoup  # $ pip install beautifulsoup4
import time
import sys
import datetime

_keywords = 'insegnamentos,cdss,sdss'
_regexp_grouped = r'([\t\s]+)?(?P<nome>(%s)+)\[(?P<codice>[0-9]+)\]( ?= ?)(?P<valore>{.*});' % _keywords.replace(',', '|')
_regexp         = r'([a-z]*)([\[0-9\]]*)( ?= ?)({.*});'
_url            = 'http://www.unical.it/portale/portaltemplates/view/view_scheda_insegnamento.cfm'

_file_to_save   = sys.argv[1]+'.%s'%datetime.datetime.now().strftime('%Y-%m-%d')

def get_page(url):
    response = urllib2.urlopen(url)
    print response.info()
    html = response.read()
    return html

def process_html(html, debug=False):
    soup = BeautifulSoup.BeautifulSoup(html)
    #script dove risiedono le informazioni utili
    #script = soup.findAll('script')[8]     #for s in soup.findAll('script'):
    #script = soup.find('script', text=re.compile(_regexp))
    script = soup.find('script', text=re.compile(_regexp_grouped, re.I))
    _lista_data = []
    _falliti = []
    for i in script.split('\n'):
        try:
            if debug: 
                print i
            r = re.match(_regexp_grouped, i, re.I)
            _lista_data.append(r.groupdict())
        except:
            if debug: 
                print 'Failed %s ...' % i[0:41]
                _falliti.append(i)

    if debug: return _lista_data, _falliti
    return _lista_data

def test(dati, random=False):
    if random: 
        while 1:
            print dati[random.randrange(1,len(dati))]
            time.sleep(0.5)
    else:
        for i in range(len(dati)):
            print dati[i]
            time.sleep(0.5)

def insegnamenti_dict(dati):
    keys = _keywords.split(',')
    d = {}
    for i in keys:
        d[i] = []
    for i in dati:
        d[i['nome']].append(i['valore'])
    return d

if __name__ == '__main__':
    html = get_page(_url)
    dati = process_html(html, debug=False)
    #test(dati)
    insegnamenti = insegnamenti_dict(dati)
    jins = json.dumps(insegnamenti)
    f = open(_file_to_save, 'w')
    f.write(jins)
    f.close()
    
