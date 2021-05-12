#!/bin/ash
## LEGO CA Certificate Request

if [[ $1 == "firstStart" ]]; then
    while [ ! -e /tmp/legoStatus ]; do sleep 1; done
    cat /tmp/legoStatus
else
    # Wait for network
    while ! route | grep default > /dev/null; do sleep 1; done

    if [ ! -e /tmp/lego ]; then
        mkdir /tmp/lego
    fi
    ng=0
    if [ ! -e /data/certs/certServer ]; then
        touch /data/certs/certServer
        chown node-red:root /data/certs/certServer
    fi
    if [[ $(cat /data/certs/certServer | head -n 1) == "" ]]; then
        echo Enter the Certificate Server Address in /data/certs/certServer
        ng=1
    fi
    if [ ! -e /data/certs/email ]; then
        touch /data/certs/email
        chown node-red:root /data/certs/email
    fi
    if [[ $(cat /data/certs/email | head -n 1) == "" ]]; then
        echo Enter the registration email in /data/certs/email
        ng=1
    fi
    if [ $ng -eq 1 ]; then
        echo Unsatisfied configuration files.  Cannot update certificates.
        exit 0
    fi

    if [ -e /data/certs/ca.crt ]; then
        cp -f /data/certs/ca.crt /usr/local/share/ca-certificates/root_ca.crt
        update-ca-certificates
    else
        echo CA Certificate must be located at /data/certs/ca.crt.
        exit 0
    fi

    domain=$(nslookup $(ifconfig $(route | grep default | awk '{print $8}') | grep "inet addr" | awk '{print $2}' | cut -d: -f2) | grep name | awk '{print $4}')
    certServer=$(cat /data/certs/certServer | head -n 1)
    email=$(cat /data/certs/email | head -n 1)
    lego -s "$certServer" -a -m "$email" -d "$domain" --http.webroot "/tmp/lego" --http.port 1081 --http --tls --http-timeout 10 renew || \
    lego -s "$certServer" -a -m "$email" -d "$domain" --http.webroot "/tmp/lego" --http.port 1081 --http --tls --http-timeout 10 run
    cp -f /root/.lego/certificates/$domain.crt /data/certs/server.crt
    chown node-red:root /data/certs/server.crt
    cp -f /root/.lego/certificates/$domain.key /data/certs/server.key
    chown node-red:root /data/certs/server.key
    echo done > /tmp/legoStatus
fi
exit 0
