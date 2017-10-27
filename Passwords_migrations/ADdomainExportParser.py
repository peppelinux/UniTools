#!/usr/bin/env python3
import re 
import json
import pprint

class ADdomainExportParser(object):
    def __init__(self, fname, fout=None, stdout=None, 
                 ancestors=None, lastlog=None, accttype=None):
        with open(fname[0]) as f:
            self.domain_text = f.read()
        # a list of dictionaries
        self.accounts = []
        self.failed = []
        self.nested = [ 'User Account Control',
                        'Ancestors',
                        'Password hashes']
        
        self.regexp_keyval = re.compile(\
        '(?P<key>[A-Za-z \-]+):[ \t]*(?P<value>[A-Za-z0-9 \.\:\+\-\@\_]+)')
        self.regexp_acct_type = re.compile(\
        '(?P<key>User Account Control):[\n\t ]*(?P<values>[A-Z\_\n\t\ ]*)Ancestors:')
        self.regexp_ancestors = re.compile(\
        '(?P<key>Ancestors):[\n\t ]*(?P<values>([a-zA-Z0-9\ \_\$\,\-\:\t\n]*))')
        self.regexp_hashes = re.compile(\
        '(?P<key>Password hashes):[\n\t ]*(?P<values>([a-zA-Z0-9\ _\$\,\.\-\:\t\n]*))')
        
        self.ancestors = ancestors if ancestors else []
        self.stdout = stdout
        if fout: 
            self.fout   = open(fout[0], 'a')
            print('Saving output in: {}'.format(fout[0]))
        else: self.fout = None
        
        self.lastlog  = lastlog if lastlog else []
        self.accttypes = accttype if accttype else []
        
    def _extract_key_val(self, value):
        res = re.match(self.regexp_keyval, value)
        if not res: 
            #~ print('Failed: {}'.format(value))
            return
        return res.groupdict()

    def _extract_subvalues(self, account):
        # now extract the subvalues with custom regexp
        acct_type = re.findall(self.regexp_acct_type, account)
        ancestors = re.findall(self.regexp_ancestors, account)
        hashes = re.findall(self.regexp_hashes, account)
        return(acct_type, ancestors, hashes)

    def _clean_subset(self, subset):
        return ''.join(list(set(subset[0][1:])))\
            .replace('\t','').replace('\n\n','\n').splitlines()

    def _filter_ancestors(self, ancestors):
        # ancestor filter :)
        for anc in self.ancestors: 
            for ancc in ancestors:
                if anc.startswith('!'):
                    if anc not in ancc: 
                        return True
                else:
                    if anc in ancc: 
                        return True

    def _filter_lastlog(self, lastlog):
        for anc in self.lastlog: 
            if anc[0] == '!' and not lastlog.startswith(anc[1:]): 
                return True
            elif anc[0] != '!' and lastlog.startswith(anc): 
                return True

    def _filter_accttype(self, accttypes):
        for anc in self.accttypes: 
            if anc.startswith('!'):
                if anc not in accttypes:
                    return True
            else:
                if anc in accttypes:
                    return True

    def _extract_account(self, account):
        account_dict = {value:None for value in self.nested}
        for i in account.splitlines():
            row = i.strip("'")
            # avoids blank lines
            if not row: continue
            spline = row.split(':')
            # means that we have a key:value pattern like "Record ID:   4052"
            if len(spline)>1 and row[0] != '\t' and spline[0] not in self.nested:
                ext = self._extract_key_val(row)
                if not ext: 
                    self.failed.append(i)
                    continue
                account_dict[ext['key']] = ext['value']
            elif len(spline)==1 and spline[0] == 'Bad password time':
                account_dict['Bad password time'] = row.replace('Bad password time',
                                              '').strip()
        # get subset
        acct_type, ancestors, hashes = self._extract_subvalues(account)
        #~ print(acct_type, ancestors, hashes)
        ancestors = ancestors[0][1:]
        account_dict[acct_type[0][0]]   = self._clean_subset(acct_type)
        account_dict[ancestors[0][0]]   = ancestors
        account_dict[hashes[0][0]]      = self._clean_subset(hashes)
        
        # filters
        if self.ancestors and not self._filter_ancestors(ancestors): return
        lastlog = account_dict.get('Last logon timestamp')
        if self.lastlog and lastlog and not self._filter_lastlog(lastlog): return
        
        accttypes = account_dict.get('User Account Control')
        #~ print(accttypes)
        if self.accttypes and \
        not self._filter_accttype(accttypes): return

        # if stdout 
        if self.stdout: 
            pprint.pprint(account_dict)
            print('\n\n')
        else: print('.'),
        
        if self.fout: json.dump(account_dict, self.fout)

    def parse(self):
        # get all but the header "\nList of users:\n==============\n"
        splitted = self.domain_text.split('Record ID:')[1:]
        for account in splitted:
            #print(account)
            self._extract_account(account)
            
    def scroll_results(self):
        from time import sleep
        for i in self.accounts:
            pprint.pprint(i)
            print('\n\n')
            sleep(1)
    
if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', nargs='+', required=True, 
    help="domain.txt extracted with command\
    'dsusers.py datatable.3 link_table.4 ../_DSoutput2 \
    --passwordhashes --lmoutfile LM.out --ntoutfile NT.out \
    --pwdformat john --syshive ../system > domain.txt'")
    parser.add_argument('-stdout', action="store_true", help="print json output")
    parser.add_argument('-o', nargs='+', help="store output in the file X.json")
    parser.add_argument('-ancestors', nargs='+', required=False, 
    help="extract only accounts that have these ancestors name, es: Ospiti. \
    This filter works like a string match")
    parser.add_argument('-last', nargs='+', required=False, 
    help="filters the accounts with last login in the date, \
    es: 2017-09-11 OR 2017-09 OR just 2017")  
    parser.add_argument('-type', nargs='+', required=False, 
    help="Account type, es: NORMAL_ACCOUNT or ") 
    args = parser.parse_args()
        
    ad = ADdomainExportParser(args.f, 
                              fout=args.o, 
                              stdout=args.stdout, 
                              ancestors=args.ancestors,
                              lastlog=args.last,
                              accttype=args.type
                              )
    ad.parse()
    
    # all the accounts will be available here:
    # ad.accounts
