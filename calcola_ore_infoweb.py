# Questo codice esemplifica un calcolo di monte ore su progetti straordinari codice 21
# la immissione di serie orarie avviene in formato stringa

timeList_dicembre = ['00:29', '01:13', '03:00', '01:23', '00:17', '01:27', '01:24', '00:49', '06:00', '02:29', '01:00', '00:38', '02:03' ]
timeList_gennaio =  [ '00:02', '00:34', '00:27', '01:13', '01:00', '00:19', '00:43', '00:02' ]

timeList_dicembre.extend(timeList_gennaio)
timeList = timeList_dicembre

def get_time_sum(timeList):
    totalSecs = 0
    for tm in timeList:
        timeParts = [int(s) for s in tm.split(':')]
        totalSecs += (timeParts[0] * 60 + timeParts[1]) # * 60 + timeParts[2]
    totalSecs, sec = divmod(totalSecs, 60)
    hr, min = divmod(totalSecs, 60)
    print "%d:%02d:%02d" % (hr, min, sec)
    return (hr, min, sec)


# questo codice esemplifica il calcolo dei secondi lavorati in una giornata (/60 minuti / 60 ore)
esempio_copia_incolla = "En 09:20      Us 14:01      En 14:51      Us 19:29 "

# gives you ['En09:20', 'Us14:01', 'En14:51', 'Us19:29']
timbrature_giorno = [i.replace(' ', '') for i in esempio_copia_incolla.split('  ') if i]

# gives you ['09:20', '14:01', '14:51', '19:29']
timbrature_giorno_noprefix = [i.replace('En', '').replace('Us', '') for i in timbrature_giorno]

# gives you [[9, 20], [14, 1], [14, 51], [19, 29]]
timbrature_giorno_int = [[int(e) for e in i.split(':')] for i in timbrature_giorno_noprefix]


def calcola_secondi_lavorati(timbr):
    """
    esempio:
    lista = ['09:20', '14:01', '']
    """
    
    dt = \
    datetime.timedelta(hours=timbr[1][0], minutes=timbr[1][1]) - \
    datetime.timedelta(hours=timbr[0][0], minutes=timbr[0][1]) + \
    datetime.timedelta(hours=timbr[3][0], minutes=timbr[3][1]) - \
    datetime.timedelta(hours=timbr[2][0], minutes=timbr[2][1])
    return dt

# in ore
calcola_secondi_lavorati(timbrature_giorno_int) / 60. / 60
# datetime.timedelta(0, 9, 316667) -> 9 ore e 32 minuti


####################################
# Altro approccio
####################################

import datetime

# ore lavorate a dicembre
ore_lavorate = '8.23,6.01,8.00,4.00,5.34,8.48,5.00,5.59,4.08,8.00,9.00,6.00,9.02,8.30,4.09,4.31'
straordinario = ',0.1,1.58,1.34,2.08,0.02,2.3'
ore_lavorate += straordinario

def totale_ore_lavorate(h_str_seq):
    """
    h_str_seq string: '8.23,6.01,8.00,4.00,5.34,8.48,5.00'
    """
    sum = datetime.timedelta()
    for i in a.split(','):
        h,m = [int(e) for e in i.split('.')]
        t = datetime.time(h,m)
        print('Sommo {} + {}'.format(sum, t), end=',')
        sum += datetime.timedelta(hours=t.hour, minutes=t.minute)
        print(' = {}'.format(sum))
    tot_ore = datetime.timedelta(seconds=sum.total_seconds())
    print('Totale ore = {}'.format(tot_ore))
    return tot_ore

totale_ore_lavorate(ore_lavorate)
