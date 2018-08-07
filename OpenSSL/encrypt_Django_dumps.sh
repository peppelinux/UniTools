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
openssl enc -aes-256-cbc -pass pass:$PASSWORD | \
gzip > $BACKUP_DIR_JSON/$FNAME.json.aes.gz

# JSON decrypt json example
# gzip -d $BACKUP_DIR/$FNAME.json.aes.gz
# openssl enc -in $BACKUP_DIR_JSON/$FNAME.json.aes -d -aes-256-cbc -pass pass:$PASSWORD

# SQL dump, encrypt and compress
mysqldump -u $USERNAME --password=$PASSWORD $DB | \
openssl enc -aes-256-cbc -pass pass:$PASSWORD | \
gzip > $BACKUP_DIR_SQL/$FNAME.sql.aes.gz

# to decompress ont of them
# first decompress with gzip, then:
# openssl enc -in $FILENAME -d -aes-256-cbc -pass pass:$PASSWORD
