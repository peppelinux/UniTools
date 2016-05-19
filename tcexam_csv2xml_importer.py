"""
he MIT License (MIT)

Copyright (c) 2016 <simonegiuseppe.malizia@unical.it>
Copyright (c) 2016 <giuseppe.demarco@unical.it>

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the "Software"), to deal 
in the Software without restriction, including without limitation the rights 
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
copies of the Software, and to permit persons to whom the Software is furnished 
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

import csv
import sys
import datetime

# csv_file_name = sys.argv[1]
csv_file_name = 'testinfo1.csv'
xml_file_name = csv_file_name.replace('.csv','')+'.xml'

print('Converting',csv_file_name,'into',xml_file_name)
print('-------')

_tcexam_version = '13.1.1'
_body_tag = 'body'
_module_tag = 'module'
_name_tag = 'name'
_enabled_tag = 'enabled'
_subject_tag = 'subject'
_head = """<?xml version="1.0" encoding="UTF-8" ?>
<tcexamquestions version="%s">
	<header lang="it" date="%s">
	</header>
""" % (_tcexam_version, datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'))


csv_file = open(csv_file_name)
csv_data = csv.reader(csv_file, delimiter='|')
xml_file = open(xml_file_name, 'w')

xml_file.write(_head)
indent = 1
xml_file.write(' '*indent*5+'<%s>' % _body_tag + '\n')
indent+=1
xml_file.write(' '*indent*5+'<%s>' % _module_tag + '\n')

row_num = 0
answ_num = 1
for row in csv_data:
    if row_num == 0:
        labels = row
        print('Labels:')
        for label in labels:
            print(label)
        print('-------')
        # replace spaces w/ underscores in labels
        for i in range(len(labels)):
            labels[i] = labels[i].replace(' ', '_')
    else: 
        map = {}
        for label,value in zip(labels,row):
            if value=="VERO":
                value="true"
            if value=="FALSO":
                value="false"
            map[label]=value
        print('Row values:')
        for label in labels:
            print(label,'=',map[label])
        print('-------')

        if(row_num == 1):
            indent+=1
            xml_file.write(' '*indent*5+'<name>'+map['name']+'</name>'+'\n')
            xml_file.write(' '*indent*5+'<enabled>'+map['enabled']+'</enabled>'+'\n')
            xml_file.write(' '*indent*5+'<%s>' % _subject_tag + '\n')
            indent+=1
            xml_file.write(' '*indent*5+'<name>'+map['name2']+'</name>'+'\n')
            xml_file.write(' '*indent*5+'<description>'+map['description']+'</description>'+'\n')
            xml_file.write(' '*indent*5+'<enabled>'+map['enabled3']+'</enabled>'+'\n')

        if answ_num == 1:
            xml_file.write(' '*indent*5+'<question>'+'\n')
            indent+=1
            xml_file.write(' '*indent*5+'<enabled>'+map['enabled4']+'</enabled>'+'\n')
            xml_file.write(' '*indent*5+'<type>'+map['type']+'</type>'+'\n')
            xml_file.write(' '*indent*5+'<difficulty>'+map['difficulty']+'</difficulty>'+'\n')
            xml_file.write(' '*indent*5+'<position>'+map['position']+'</position>'+'\n')
            xml_file.write(' '*indent*5+'<timer>'+map['timer']+'</timer>'+'\n')
            xml_file.write(' '*indent*5+'<fullscreen>'+map['fullscreen']+'</fullscreen>'+'\n')
            xml_file.write(' '*indent*5+'<inline_answers>'+map['inline_answers']+'</inline_answers>'+'\n')
            xml_file.write(' '*indent*5+'<auto_next>'+map['auto_next']+'</auto_next>'+'\n')
            xml_file.write(' '*indent*5+'<description>'+map['description5']+'</description>'+'\n')
            xml_file.write(' '*indent*5+'<explanation>'+map['explanation']+'</explanation>'+'\n')

        xml_file.write(' '*indent*5+'<answer>'+'\n')
        indent+=1     
        xml_file.write(' '*indent*5+'<enabled>'+map['enabled6']+'</enabled>'+'\n')
        xml_file.write(' '*indent*5+'<isright>'+map['isright']+'</isright>'+'\n')
        xml_file.write(' '*indent*5+'<position>'+map['position7']+'</position>'+'\n')
        xml_file.write(' '*indent*5+'<keyboard_key>'+map['keyboard_key']+'</keyboard_key>'+'\n')
        xml_file.write(' '*indent*5+'<description>'+map['description8']+'</description>'+'\n')
        xml_file.write(' '*indent*5+'<explanation>'+map['explanation9']+'</explanation>'+'\n')
        indent-=1            
        xml_file.write(' '*indent*5+'</answer>'+'\n')
        answ_num+=1
        
        if answ_num == 5:
            indent-=1
            xml_file.write(' '*indent*5+'</question>'+'\n')
            answ_num = 1

    row_num +=1

indent-=1
xml_file.write(' '*indent*5+'</%s>' % _subject_tag + '\n')
indent-=1
xml_file.write(' '*indent*5+'</%s>' % _module_tag + '\n')
indent-=1
xml_file.write(' '*indent*5+'</%s>' % _body_tag + '\n')
indent-=1
xml_file.write(' '*indent*5+'</tcexamquestions>' + '\n')

xml_file.close()
csv_file.close()

