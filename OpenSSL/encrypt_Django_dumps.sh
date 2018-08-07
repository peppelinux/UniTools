
#!/bin/bash

# https://blog.khophi.co/django-management-commands-via-cron/
source /opt/django_peo.env/bin/activate && \
cd /opt/django_peo && \
export PASSWORD=$(python -c "from django_peo import settingslocal; print(settingslocal.DATABASES['default']['PASSWORD'])")
export USERNAME=$(python -c "from django_peo import settingslocal; print(settingslocal.DATABASES['default']['USER'])")
export DB=$(python -c "from django_peo import settingslocal; print(settingslocal.DATABASES['default']['NAME'])")

BACKUP_DIR="/opt/django_peo_dumps"
BACKUP_DIR_JSON=$BACKUP_DIR"/json"
BACKUP_DIR_SQL=$BACKUP_DIR"/sql"
FNAME="peo.$(date +"%Y-%m-%d_%H:%M:%S")" 

# JSON dump, encrypt and compress
./manage.py dumpdata --exclude auth.permission --exclude contenttypes --exclude csa --indent 2 | \
gzip | \
openssl enc -aes-256-cbc -pass pass:$PASSWORD > $BACKUP_DIR_JSON/$FNAME.json.gz.aes

# JSON decrypt json example
# openssl enc -in $BACKUP_DIR_JSON/$FNAME.json.gz.aes -d -aes-256-cbc -pass pass:$PASSWORD | gzip -d -

# SQL dump, encrypt and compress
mysqldump -u $USERNAME --password=$PASSWORD $DB | \
gzip | \
openssl enc -aes-256-cbc -pass pass:$PASSWORD > $BACKUP_DIR_SQL/$FNAME.sql.gz.aes

# to decompress ont of them
# openssl enc -in $FILENAME -d -aes-256-cbc -pass pass:$PASSWORD | gzip -d -
