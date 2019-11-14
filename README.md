# lets-encrypt-spring-boot
A simple spring boot service protected by lets encrypt certificates


## 1) Creating the lets encrypt certificates (assumes you have installed certbot)

* Domain is "orono.stream", generating a "wildcard" certficate which will server any host under this domain. 

```
certbot certonly --server https://acme-v02.api.letsencrypt.org/directory \ 
  --agree-tos --cert-name orono.stream -d '*.orono.stream' -m <your-email> \ 
  --config-dir ./config --logs-dir ./logs --work-dir ./work --manual --preferred-challenges dns
```

Once you have completed the DNS challenge, this will create files in the ./config/live/cert-name/ directory. 

```
  README		cert.pem	chain.pem	fullchain.pem	privkey.pem
```
  
  
## 2) Create a PKCS12 type truststore

Replace the values ***alias*** and ***password***
```
openssl pkcs12 -export -in cert.pem -inkey privkey.pem \
               -out keystore.p12 -name ***alias*** \
               -CAfile fullchain.pem -caname root -password pass:***password***
```
               
## 3) Create a JKS type truststore (required by java spring boot service)

Replace the 3 occurrences of ***password*** and ***alias*** from step 2.
```
    keytool -importkeystore -deststorepass ***password*** -destkeypass ***password*** \ 
    -destkeystore keystore.jks -srckeystore keystore.p12 -srcstoretype PKCS12 \
    -srcstorepass ***password***  -alias ***alias***
```

For convenience, the script keystore.sh can be run from your certificate directory to perform steps 2 & 3. 

## 4) Create the Spring Boot Service

* Use start.spring.io to create a new application selecting the web depenedency and any others you need. 

* Copy the _keystore.jks_ from step 3 to the _/src/main/resources_ directory under your project. 

* add the following properties to your application.yaml (replacing password and alias from step 2)
```
server:
  port: 8443
  ssl:
    enabled: true
    key-store: classpath:keystore.jks
    key-alias: tomcat
    key-store-password: paspas
    key-store-provider: SUN
    key-store-type: JKS

```

## 5) Run the service

* Run the service 
```
mvn spring-boot:run
```

* At startup you should see the message, showing that it is using ***https***
```
Tomcat started on port(s): 8443 (https) with context path ''
```

## 6) Verify the service

![screenshot](https://raw.githubusercontent.com/bmullan-pivotal/lets-encrypt-spring-boot/master/orono-screenshot.png)

