
export FNAME="file_name.txt"
export SUFFIX=".aes"

openssl enc -in $FNAME -aes-256-cbc -pass pass:yourpassword > $FNAME$SUFFIX
openssl enc -in $FNAME$SUFFIX -d -aes-256-cbc -pass pass:yourpassword #> logfile.x.log
