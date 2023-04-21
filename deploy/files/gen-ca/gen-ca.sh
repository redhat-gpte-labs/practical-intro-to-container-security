#!/bin/bash

set -xeuo pipefail

mkdir -p /root/CA

# Generate the CA Certificate
openssl genrsa -out /root/CA/CA_key.pem 2048
openssl req -x509 \
  -new \
  -nodes \
  -sha256 \
  -days 3650 -key /root/CA/CA_key.pem -out /root/CA/CA_cert.pem -subj "/O=Red Hat Lab/CN=Lab CA"

# # Update the CA trust store
# cp /root/CA/CA_cert.pem /etc/pki/ca-trust/source/anchors
# update-ca-trust
