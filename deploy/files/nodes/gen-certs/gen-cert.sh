#!/bin/bash

set -xeuo pipefail

openssl genrsa -out myserver.key 2048

openssl req -new \
  -key myserver.key -out myserver.csr -config certificate.cnf

openssl x509 -req \
  -in myserver.csr -out myserver.pem \
  -CA CA/CA_cert.pem -CAkey CA/CA_key.pem -CAcreateserial \
  -days 365 -sha256 -extfile certificate.cnf
