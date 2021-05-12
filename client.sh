#!/bin/ash
## LEGO CA Certificate Request

# Wait for network
while ! route | grep default > /dev/null; do sleep 1; done

if [ ! -e /tmp/lego ]; then
    mkdir /tmp/lego
fi
ng=0
if [ ! -e /data/certs/certServer ]; then
    touch /data/certs/certServer
fi
if [[ $(cat /data/certs/certServer | head -n 1) == "" ]]; then
    echo Enter the Certificate Server Address in /data/certs/certServer
    ng=1
if [ ! -e /data/certs/email ]; then
    touch /data/certs/email
fi
if [[ $(cat /data/certs/email | head -n 1) == "" ]]; then
    echo Enter the registration email in /data/certs/email
    ng=1
fi
if [ $ng -eq 1 ]; then
    echo Unsatisfied configuration files.  Cannot update certificates.
    exit 0
fi
    
copy -f /data/certs/ca.crt /usr/local/share/ca-certificates/root_ca.crt
update-ca-certificates
lego -s "$(cat /data/certs/certServer | head -n 1)" -a -m "$(cat /data/certs/email | head -n 1)" -d "$(nslookup $(ifconfig $(route | grep default | awk '{print $8}') | grep "inet addr" | awk '{print $2}' | cut -d: -f2) | grep name | awk '{print $4}')" --http.webroot "/tmp/lego" --http.port 1081 --http --tls --http-timeout 10 renew || \
lego -s "$(cat /data/certs/certServer | head -n 1)" -a -m "$(cat /data/certs/email | head -n 1)" -a -m "$(cat /data/certs/email | head -n 1)" -d "$(nslookup $(ifconfig $(route | grep default | awk '{print $8}') | grep "inet addr" | awk '{print $2}' | cut -d: -f2) | grep name | awk '{print $4}')" --http.webroot "/tmp/lego" --http.port 1081 --http --tls --http-timeout 10 run
cp -f /root/.lego/certificates/$(nslookup $(ifconfig $(route | grep default | awk '{print $8}') | grep "inet addr" | awk '{print $2}' | cut -d: -f2) | grep name | awk '{print $4}').crt /data/certs/server.crt
cp -f /root/.lego/certificates/$(nslookup $(ifconfig $(route | grep default | awk '{print $8}') | grep "inet addr" | awk '{print $2}' | cut -d: -f2) | grep name | awk '{print $4}').key /data/certs/server.key

exit 0
