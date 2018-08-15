#!/bin/bash

if [ ! -e server.js ]
then
	echo "Error: could not find main application server.js file"
	echo "You should run the generate-ssl-certs.sh script from the main application root directory"
	echo "i.e: bash scripts/generate-ssl-certs.sh"
	exit -1
fi

if [ $# -lt 2 ]
then
    echo "Error: NODE_ENV ($1) and PASS ($2) are mandatory"
    exit -1
fi

NODE_ENV=$1
PASS=$2

country=$(node -pe 'JSON.parse(process.argv[1]).server.sslgenerator.country' "$(cat config/$NODE_ENV.json)")
state=$(node -pe 'JSON.parse(process.argv[1]).server.sslgenerator.state' "$(cat config/$NODE_ENV.json)")
location=$(node -pe 'JSON.parse(process.argv[1]).server.sslgenerator.location' "$(cat config/$NODE_ENV.json)")
organization=$(node -pe 'JSON.parse(process.argv[1]).server.sslgenerator.organization' "$(cat config/$NODE_ENV.json)")
website=$(node -pe 'JSON.parse(process.argv[1]).server.sslgenerator.website' "$(cat config/$NODE_ENV.json)")
emailAddress=$(node -pe 'JSON.parse(process.argv[1]).server.sslgenerator.emailAddress' "$(cat config/$NODE_ENV.json)")
key=$(node -pe 'JSON.parse(process.argv[1]).server.key' "$(cat config/$NODE_ENV.json)")
cert=$(node -pe 'JSON.parse(process.argv[1]).server.cert' "$(cat config/$NODE_ENV.json)")

openssl genrsa -out $key 1024
openssl req -new -key $key -out ./config/csr.pem -subj "/C=$country/ST=$state/L=$location/O=$organization/OU=IT Department/CN=$website/emailAddress=$emailAddress/challengePassword=$PASS"
openssl x509 -req -days 9999 -in ./config/csr.pem -signkey $key -out $cert
rm ./config/csr.pem
chmod 600 $key $cert
