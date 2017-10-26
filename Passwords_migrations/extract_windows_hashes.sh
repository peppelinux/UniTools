# http://blog.ericjonwalker.com/
# https://xinn.org/blog/JtR-AD-Password-Auditing.html

# first of all we have to extract the Windows hashesh
# open a CMD with Administrator privileges (uncheck the limited privileges) and run

Vssadmin create shadow /For=c:

# The Shadow ID could be different from 1, adapt it
Copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\NTDS\ntds.dit .
Copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\System32\config\SYSTEM .

Vssadmin delete shadows /For=C: /All

# now copy ntds.dit and system files into your linux box :)
apt install libesedb-utils 

ls 
# ntds.dit  SAM  system

esedbexport ntds.dit 
# it will create a subfolder called: ntds.dit.export
cd ntds.dit.export
dsusers.py datatable.3 link_table.4 ../_DSoutput2 --passwordhashes --lmoutfile LM.out --ntoutfile NT.out --pwdformat john --syshive ../system > domain.txt

# everything with its NT hashes is right here
cat domain.txt

