import datetime
import os

# peppelinux 10 agosto 2014 - giuseppe.demarco@unical.it

# costanti
permitted_days = [15, 1]
target_dirs     = [ 'CLA', 'Moodle' ]

for d in target_dirs:
    print 'working on', d
    lista_files = os.listdir(d)
    #print lista_files
    for f in lista_files:
        ffile = d.lower() + '-%Y-%m-%d.sql'
        data_file = datetime.datetime.strptime( f, ffile)
        if data_file.day not in permitted_days:
            print 'cancello %s' % f
            os.remove(d + os.path.sep + f)
