export USER='slapd'
export PASS='slapdsecret'
export HOST='%'
export DB='slapd'

mysql -u root -e "\
CREATE USER ${USER}@'${HOST}' IDENTIFIED BY '${PASS}';\
CREATE DATABASE ${DB};\
GRANT ALL PRIVILEGES ON ${DB}.* TO ${USER}@'${HOST}';"
