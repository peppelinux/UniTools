# Questo codice esemplifica un calcolo di monte ore effettuato mediante 
# la immissione di serie orarie in formato stringa, corrispondenti agli ingressi e alle uscite

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
