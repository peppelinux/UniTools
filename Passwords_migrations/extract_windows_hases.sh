apt install libesedb-utils 

ls 
# ntds.dit  SAM  system

esedbexport ntds.dit 
# it will create a subfolder called: ntds.dit.export
cd ntds.dit.export
dsusers.py datatable.3 link_table.4 ../DSoutput --active --ntoutfile NT-hashes 
