# http://blog.ericjonwalker.com/
# https://xinn.org/blog/JtR-AD-Password-Auditing.html

apt install libesedb-utils 

ls 
# ntds.dit  SAM  system

esedbexport ntds.dit 
# it will create a subfolder called: ntds.dit.export
cd ntds.dit.export
dsusers.py datatable.3 link_table.4 ../_DSoutput2 --passwordhashes --lmoutfile LM.out --ntoutfile NT.out --pwdformat john --syshive ../system 

