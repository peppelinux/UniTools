#!/usr/bin/env python3
import re 
import json
import pprint
import os

class ADdomainExportParser(object):
    def __init__(self, fname, fout=None, stdout=None, 
                 ancestors=None, lastlog=None, accttype=None,
                 user_pname=None):
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
        '(?P<key>Ancestors):[\n\t ]*(?P<values>[a-zA-Z0-9\ \.\_\$\,\-\:\t\n]*)Password hashes:')
        self.regexp_hashes = re.compile(\
        '(?P<key>Password hashes):[\n\t ]*(?P<values>([a-zA-Z0-9\ _\$\,\.\-\:\t\n]*))')
        
        self.ancestors = ancestors if ancestors else []
        self.stdout = stdout[0] if stdout else None
        
        if fout: 
            fout = fout[0]
            self.fout = fout
            if not os.path.exists(fout):
                os.makedirs(fout)
            print('Saving output in: {}'.format(fout))
        else: self.fout = None
        
        self.lastlog  = lastlog if lastlog else []
        self.accttypes = accttype if accttype else []
        self.user_pname = user_pname if user_pname else []
        
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
        # if subset has no value return False
        if len(subset) == 0 or len(subset[0]) == 0: return 
        lsub = list(set(subset[0][1:]))
        return ''.join(lsub)\
            .replace('\t','').replace('\n\n','\n').splitlines()

    def _filter_ancestors(self, ancestors):
        # ancestor filter :)
        if not self.ancestors: return True
        for anc in self.ancestors: 
            for ancc in ancestors:
                if anc.startswith('!'):
                    if anc not in ancc[1]: 
                        return True
                else:
                    if anc in ancc[1]: 
                        return True

    def _filter_lastlog(self, lastlog):
        if not self.lastlog: return True        
        for anc in self.lastlog: 
            if anc[0] == '!' and not lastlog.startswith(anc[1:]): 
                return True
            elif anc[0] != '!' and lastlog.startswith(anc): 
                return True

    def _filter_accttype(self, accttypes):
        if not self.accttypes: return True
        for anc in self.accttypes: 
            if anc.startswith('!'):
                if anc not in accttypes:
                    return True
            else:
                if anc in accttypes:
                    return True

    def _filter_user_pname(self, user_pname):
        if not self.user_pname: return True        
        for us in self.user_pname: 
            if us[0] == '!' and not us[1:] in user_pname: 
                return True
            elif us[0] != '!' and us in user_pname: 
                return True
    
    def _print_stdout(self, acct_dict):
        #~ print(acct_dict)
        if self.stdout == 'radcheck':
            username = acct_dict['User principal name']
            try:
                password = acct_dict['Password hashes'][0].split(':')[1].strip('$NT$')
            except:
                password = ''
                return
            
            exp = acct_dict["Account expires"] 
            print({
                    'username': username,
                    'attribute': 'NT-Password',
                    'op': ':=',
                    'value': 'NON-VISIBILE :)', #password,
                    'is_active': 1,
                    'created': acct_dict['When changed'],
                    'modified': acct_dict['Password last set'],
                    'expires': exp if exp != 'Never' else 'NULL',
                  })
            
            
        elif self.stdout == 'json':
            pprint.pprint(account_dict)
            print('\n\n')
        else: print('.', end='')
    
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
            elif len(spline)==1 and spline[0].startswith('Bad password time'):
                account_dict['Bad password time'] = row.replace('Bad password time',
                                              '').strip()
        # get subset
        acct_type, ancestors, hashes = self._extract_subvalues(account)
        
        if acct_type:
            account_dict[acct_type[0][0]]   = self._clean_subset(acct_type)
        if ancestors:
            account_dict[ancestors[0][0]]   = self._clean_subset(ancestors)
        if hashes:
            account_dict[hashes[0][0]]      = self._clean_subset(hashes)
        
        # filters
        if self.ancestors and not self._filter_ancestors(ancestors): return
        
        lastlog = account_dict.get('Last logon timestamp')
        if self.lastlog and lastlog and not self._filter_lastlog(lastlog): return
        
        accttypes = account_dict.get('User Account Control')
        if self.accttypes and \
        not self._filter_accttype(accttypes): return
        
        if self.user_pname and \
        not self._filter_user_pname(account_dict['User principal name']): return
        # and filters checks
        
        # if stdout 
        if self.stdout: 
            self._print_stdout(account_dict)
        
        self.accounts.append(account_dict)
        if self.fout: 
            fout_path = os.path.sep.join((self.fout, account_dict['User principal name']))
            with open(fout_path, 'w') as fout:
                json.dump(account_dict, fout)
        
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
            sleep(0.5)

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', nargs='+', required=True, 
    help="domain.txt extracted with command\
    'dsusers.py datatable.3 link_table.4 ../_DSoutput2 \
    --passwordhashes --lmoutfile LM.out --ntoutfile NT.out \
    --pwdformat john --syshive ../system > domain.txt'")
    parser.add_argument('-stdout', nargs=1, help="print output, \
    json or radcheck tuple", required=False)    
    parser.add_argument('-o', nargs='+', help="store outputs in the folder called with this name")
    parser.add_argument('-ancestors', nargs='+', required=False, 
    help="extract only accounts that have these ancestors name, es: Ospiti. \
    This filter works like a string match. \!Ospiti means to exclude them")
    parser.add_argument('-user_pname', nargs='+', required=False, 
    help="extract only accounts that contains (or not) that words in \
    the User Principal name, es: dipendenti, studenti or \\!dipendenti")
    parser.add_argument('-last', nargs='+', required=False, 
    help="filters the accounts with last login in the date, \
    es: 2017-09-11 OR 2017-09 OR just 2017.\
    \!2017 means to exclude them")  
    parser.add_argument('-type', nargs='+', required=False, 
    help="Account type, es: NORMAL_ACCOUNT or ACCOUNTDISABLE. \
    \!ACCOUNTDISABLE means to exclude them") 
    args = parser.parse_args()

    ad = ADdomainExportParser(args.f, 
                              fout=args.o, 
                              stdout=args.stdout, 
                              ancestors=args.ancestors,
                              lastlog=args.last,
                              accttype=args.type,
                              user_pname=args.user_pname
                              )
    ad.parse()
    
    # all the accounts will be available here:
    # ad.accounts
    print('{} processed'.format(len(ad.accounts)))
