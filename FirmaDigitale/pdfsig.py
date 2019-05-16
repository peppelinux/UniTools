#/usr/bin/env python3

import json
import re
import os
import subprocess

from collections import OrderedDict


if os.system('pdfsig -v') != 0:
    raise Exception(('pdfsig is not installed.'
                     'Please install poppler or poppler-utils'))

_FNAME = "/home/wert/Scrivania/Modello 04-Richiesta_Registrazione_DNS04_v2_signable.pdf"
_ATTRIBUTES = ['Signature Type',
               'Signature Validation',
               'Signer Certificate Common Name',
               'Signer full Distinguished Name',
               'Signing Hash Algorithm',
               'Signing Time']


def get_signatures(fname, only_valids=False):
    raw_result = subprocess.check_output(['pdfsig', fname]).decode('utf-8')
    result = re.split('Signature #[0-9]+:\n', raw_result)

    pdf_name = result[0]
    signatures = result[1:]
    if only_valids:
        filter_out = "Signature Validation: Signature has not yet been verified"
        valid_signatures = [i.strip() for i in signatures if filter_out not in i]
    else:
        valid_signatures = [i.strip() for i in signatures]

    re.search('Signature #(?P<n>[0-9]+):(?P<content>[\t\n\w\s\:\-\_\.A-Za-z\,\=\[\]\(\)]*)',
              raw_result).groups()

    cleaned_signatures = []
    for i in valid_signatures:
        d = OrderedDict()
        splitted = i.split('\n')
        for s in splitted:
            cleaned_s = re.sub('^[\s\-]+', '', s)
            splitc = cleaned_s.partition(':')
            k, v = splitc[0].strip(), splitc[2].strip()
            if k in _ATTRIBUTES:
                d[k] = v
        cleaned_signatures.append(d)
    return cleaned_signatures


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', required=False, action='store_true',
                        help="returns onvly valids signs")
    parser.add_argument('-f', required=True,
                        help="pdf filename to inspect")
    args = parser.parse_args()

    print(json.dumps(get_signatures(args.f, args.v), indent=2))
