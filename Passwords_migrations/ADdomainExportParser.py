#!/usr/bin/env python3
import re 
import json
import pprint

class ADdomainExportParser(object):
    def __init__(self, fname, fout=None, stdout=None):
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
        
        self.stdout = stdout
        if fout: 
            self.fout   = open(fout[0], 'a')
            print('Saving output in: {}'.format(fout[0]))
        else: self.fout = None
        
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
        
        acct_type, ancestors, hashes = self._extract_subvalues(account)
        #~ print(acct_type, ancestors, hashes)
        account_dict[acct_type[0][0]]   = ''.join(acct_type[0][1:])\
            .replace('\t','').replace('\n\n','\n').splitlines()
        account_dict[ancestors[0][0]]   = ancestors[0][1:]
        account_dict[hashes[0][0]]      = ''.join(hashes[0][1:])\
            .replace('\t','').replace('\n\n','\n').splitlines()
        
        self.accounts.append(account_dict)
        
        if self.stdout: pprint.pprint(account_dict)
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
    parser.add_argument('-f', nargs='+', required=True, help="domain.txt extracted with command\
    'dsusers.py datatable.3 link_table.4 ../_DSoutput2 --passwordhashes --lmoutfile LM.out --ntoutfile NT.out --pwdformat john --syshive ../system > domain.txt'")
    parser.add_argument('-stdout', action="store_true", help="print json output")
    parser.add_argument('-o', nargs='+', help="store output in the file X.json")
    args = parser.parse_args()
        
    ad = ADdomainExportParser(args.f, args.o, args.stdout)
    ad.parse()
    
    # all the accounts will be available here:
    # ad.accounts
