# System dependencies
 ````
  aptitude  install build-essential
  aptitude  install python-pip python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev
 ````

# Create a virtual environment
 ````
 pip install virtualenv		
 virtualenv fabric_provisioning
 source fabric_provisioning/bin/activate	
 pip install -r requirements.txt
 ````		

# Ssh connections

Server A, client B.
Connecting from B to A, run on B:
 
 ````
 ssh-keygen -t rsa
 ssh-copy-id -i ~/.ssh/id_rsa.pub $A_HOSTNAME
 ````		
