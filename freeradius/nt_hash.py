import sys
from passlib.hash import nthash

_help = """
dependencies:
    pip install passlib

just type:
    python nt_hash.py password

"""

if len(sys.argv) < 2:
    sys.exit(_help)

nt_hash = nthash.hash(sys.argv[1])
print(nt_hash)
