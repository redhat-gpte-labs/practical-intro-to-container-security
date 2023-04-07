#!/bin/bash

set -xeuo pipefail

touch myserver.key
chmod 600 myserver.key
openssl req -new -newkey rsa:4096 -nodes -sha256 -config myserver.cnf -keyout myserver.key -out myserver.csr
openssl x509 -signkey myserver.key -in myserver.csr -req -days 2000 -out myserver.cert -extensions req_ext -extfile myserver.cnf
openssl x509 -noout -in myserver.cert -serial -issuer -dates -subject -ext subjectAltName
