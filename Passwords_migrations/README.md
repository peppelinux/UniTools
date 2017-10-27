usage: ADdomain_parser.py [-h] -f F [F ...] [-stdout] [-o O [O ...]]

optional arguments:
  -h, --help    show this help message and exit
  -f F [F ...]  domain.txt extracted with command 'dsusers.py datatable.3
                link_table.4 ../_DSoutput2 --passwordhashes --lmoutfile LM.out
                --ntoutfile NT.out --pwdformat john --syshive ../system >
                domain.txt'
  -stdout       print json output
  -o O [O ...]  store output in the file X.json
