SETUP
=======================

# system dependencies
aptitude  install build-essential
aptitude  install python-pip python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev

# first create a virtualenvironment
# pip install virtualenv

virtualenv fabric_provisioning
source fabric_provisioning/bin/activate
pip install -r requirements.txt


SSH CONNECTION
=======================

# Server A, client B
# Connecting from B to A, run on B:
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub $A_HOSTNAME
