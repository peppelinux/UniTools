# -*- coding: utf-8 -*-
import httplib, urllib
import sys
import re

# example
# fab -H 10.0.17.1,10.0.17.10,10.0.17.11,10.0.17.12,10.0.17.13,10.0.17.14,10.0.17.15,10.0.17.16,10.0.17.17,10.0.17.18,10.0.17.19,10.0.17.2,10.0.17.20,10.0.17.21,10.0.17.22,10.0.17.23,10.0.17.24,10.0.17.25,10.0.17.27,10.0.17.28,10.0.17.29,10.0.17.3,10.0.17.31,10.0.17.4,10.0.17.5,10.0.17.6,10.0.17.7,10.0.17.8,10.0.17.9,10.10.17.150,10.10.17.32,10.0.17.30 -u user -p passwd -P put_file:/storage/Progs/Shell_Reports.zip,/home/cla/Scrivania/Shell_Reports.zip

try: 
    from pyquery import PyQuery as pq
except:
    print 'Please install PyQuery first.\npip install pyquery'
    sys.exit(1)

# configurazione default
_sep = ';'
_encoding = 'iso-8859-1'
#_encoding = 'utf-8'
_url = 'www.unical.it'
_path='/portale/portaltemplates/view/search_phone.cfm'
_struttura = "Dipartimento di Ingegneria per l'Ambiente e il Territorio e Ingegneria Chimica"
_dict_params = {'Q_FOL':'/', 'Q_TIPO':'struttura', 'Q_RU_COGNOME': '', 'Q_RU_TELEFONO': '', 'Q_RU_STRUTTURA': _struttura}

# se volessimo specificare manualmente la struttura
if len(sys.argv)>1:
    _dict_params['Q_RU_STRUTTURA'] = sys.argv[1]

_params = urllib.urlencode(_dict_params)
_headers = {"Content-type": "application/x-www-form-urlencoded", "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"}

_regexp_person = '^[^\\\/-]*$[\D]*'
_regexp_phone  = '[0-9]'


class HtmlParser(object):
    def __init__(self, data):
        self.pd = pq(data)
        self.jq_select = None
        
    def get_jquery_select(self, jqselect):
        """
            pd('b')
            pd('span b')
            pd('span:contains("-")')
            
            jqselect = 'span:contains("-")'
        """
        self.jq_select = self.pd(jqselect)
        return self.jq_select
    
    

class UniPhoneScaper(object):
    def __init__(self, url=_url, path=_path, params=_params, headers=_headers):
        self.url     = url
        self.path    = path
        self.params  = params
        self.headers = headers
        self.texts = []
        self.phonebooks = {}
		
    def close(self):
        self.conn.close()       
    
    def get_html(self):
        self.data = self.response.read()
    
    def connect(self):
        self.conn = httplib.HTTPConnection(_url)
        self.conn.request("POST", self.path, self.params, self.headers)
        self.response = self.conn.getresponse()
        print self.response.status, self.response.reason
    
    def parse_html(self):
        self.jquery  = HtmlParser(self.data)
    
    def get_strutture(self):
        self.strutture = []
        
        for i in self.jquery.get_jquery_select('[name="Q_RU_STRUTTURA"] option'):
            i_clean = re.sub('[\n\t\r]+', '', i.text_content())
            self.strutture.append( i_clean.encode(_encoding).decode('utf-8'))
        return self.strutture
        
    def get_elements_text(self, jqfilter):
        """ 
            jqfilter = 'span:contains("-")' 
        """
        for i in self.jquery.get_jquery_select(jqfilter):
            if i.text_content():
                #print i.text_content().encode(_encoding).decode('utf-8')
                self.texts.append( i.text_content().encode(_encoding).decode('utf-8') )
				
    def extract_phonebook(self):
        phonebook = self.phonebooks[ self.texts[0] ] = []
        diz = {'numero':[], 'nome': [], 'cognome': []}
        for i in self.texts[1:]:
            # estraggo la persona
            persona = ' '.join(re.findall(_regexp_person, i, re.UNICODE|re.IGNORECASE)).strip()
            numero  = ''.join(re.findall(_regexp_phone, i, re.UNICODE|re.IGNORECASE))
            
            if persona: 
                # se abbiamo una nuova corrispondenza salvo la precedente 
                if diz['nome']: 
                    phonebook.append(diz)
                    diz = {'numero':[], 'nome':[], 'cognome':[]}
                persona_clean = re.sub(' +', ' ', persona)
                
                # il cognome è sempre tutto maiuscolo
                for n in persona_clean.split(' '):
                    if n.isupper(): diz['cognome'].append( n )
                    else:           diz['nome'].append(n)

            if numero :
                diz['numero'].append('0039 '+numero)
        
if __name__ == '__main__':
    
    uniscrap = UniPhoneScaper()
    uniscrap.connect()
    uniscrap.get_html()
    uniscrap.parse_html()
    uniscrap.get_elements_text('b')
    try: uniscrap.extract_phonebook()
    except: 
        
        print "Nome struttura non corrispondente tra quelle disponibili"; 
        for i in uniscrap.get_strutture():
            print i
        sys.exit(1)
    #print uniscrap.phonebooks
    uniscrap.close()
    
    #print uniscrap.phonebooks
    
    for i in uniscrap.phonebooks:
        print i
        print _sep.join(('nome', 'cognome', 'numero'))
        for v in uniscrap.phonebooks[i]:
            print _sep.join(( ' '.join(v['nome'])\
                                               ,' '.join(v['cognome'])\
                                               ,' '.join(v['numero'])))
