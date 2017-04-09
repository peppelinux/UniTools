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

If password could be still necessary you can always pass it as argument. This installs Tomcat7
````
fab install_tomcat7_idp -u root -p vagrant
````
