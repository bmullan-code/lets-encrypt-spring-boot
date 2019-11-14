#!/bin/bash
# use keystore.sh <alias> <password>
if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
else 
	echo "good"
	openssl pkcs12 -export -in cert.pem -inkey privkey.pem \
               -out keystore.p12 -name $1 \
               -CAfile fullchain.pem -caname root -password pass:$2

    keytool -importkeystore -deststorepass $2 -destkeypass $2 -destkeystore keystore.jks \
    -srckeystore keystore.p12 -srcstoretype PKCS12 -srcstorepass $2  -alias $1

fi

