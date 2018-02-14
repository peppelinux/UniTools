
DNS_SERVER="160.97.7.13"
MUL_FACTOR=0.000277
echo "Usage: thicommand host.domani.to.check"

host -v $1 $DNS_SERVER | grep SOA | head -1 | awk -F' ' {'print $2'}  | awk '{printf "%4.3f\n",$0*$MUL_FACTOR}'
