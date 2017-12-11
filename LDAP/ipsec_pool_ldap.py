#!/usr/bin/env python3

# pip install ldap3
from copy import copy
from subprocess import check_output
import ldap3

_SERVER_HOST='hostname.domain.it'
_USER="cn=USERCN,dc=DOMAIN,dc=it"
_PASSWD='PUT_SECRET_HERE'
_ATTRIBUTES=['uid',
             'cn', 
             'sn', 
             'mail', 
             #~ 'objectclass',
             ]

def get_accounts(conn, uids):
    accounts = []
    for i in uids:
        conn.search('ou=GROUP,ou=People,dc=DOMAIN,dc=it',
                    '(&(objectclass=person)(uid={}))'.format(i),
                    attributes=_ATTRIBUTES)
        for e in conn.entries:
            accounts.append(e.entry_attributes_as_dict)
    return accounts

def data_orig2dicts(data_orig):
    l = []
    for i in data_orig[1:]:
        data = [ e for e in i.split(' ') if len(e)>1]
        #~ print(data)
        if data[2] == 'online':
            l.append({
                        'name': data[0], 
                        'address': data[1], 
                        'status': data[2], 
                        'start': ' '.join((data[3],data[4],data[5],data[6])), 
                        'end': '', 
                        'identity': data[7]
                    })
        else:
            l.append({
                        'name': data[0], 
                        'address': data[1], 
                        'status': data[2], 
                        'start': ' '.join((data[3],data[4],data[5],data[6])), 
                        'end': ' '.join((data[7],data[8],data[9],data[10])), 
                        'identity': data[11]
                    })
    return l

def get_extended_row(data_dict_row, accounts):
    #~ print(data_dict_row)
    d = copy(data_dict_row)
    identity = d['identity']
    for a in accounts:
        if a['uid'][0] == identity:
            d['mail'] = a['mail'][0]
            d['uid'] = a['uid'][0]
            d['cn'] = a['cn'][0]
    return d
    

if __name__ == '__main__':
    ipsec_pool_leases=check_output(['ipsec', 'pool', '--leases']).decode('ascii')
    
    data_orig = ipsec_pool_leases.splitlines()
    data_head = [ i for i in data_orig[0].split(' ') if i]
    
    processed_uid = []
    for i in data_orig[1:]:
        uid = i.split(' ')[-1]
        if uid not in processed_uid:
            processed_uid.append(uid)
    
    server = ldap3.Server('_SERVER_HOST', port = 636, use_ssl = True,
                      get_info=ldap3.ALL)  # define a secure LDAP server
    conn = ldap3.Connection(server,
                        user=_USER,
                        password=_PASSWD,
                        auto_bind=True)
    #server.info
    #server.schema
    print('Currently logged as: "{}"'.format(conn.extend.standard.who_am_i()))
    accounts = get_accounts(conn, processed_uid)
    data_dict = data_orig2dicts(data_orig)
    #print(accounts)
    #print(data_dict)
    new_head = data_head+['mail'] #, 'cn']
    new_data = []
    for i in data_dict:
        ext_row = get_extended_row(i,accounts)
        new_data.append(ext_row)
        for he in new_head:
            print(ext_row[he]+' ', end='')
        print()
