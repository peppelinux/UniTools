apt install libesedb-utils 

ls 
# ntds.dit  SAM  system

esedbexport ntds.dit 
# it will create a subfolder called: ntds.dit.export
