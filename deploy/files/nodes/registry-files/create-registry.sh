#!/bin/bash
#
# Before running this script, generate SSL certificates (see gen-certs/gen-cert.sh).
set -euo pipefail

LOCAL_PORT=5000
STORAGE_DIR=${HOME}/storage/registry
DATA_DIR=${STORAGE_DIR}/data
AUTH_DIR=${STORAGE_DIR}/auth
CERTS_DIR=${STORAGE_DIR}/certs
NAME=registry
IMAGE=docker.io/library/registry:2
TLS_CERT=myserver.pem
TLS_KEY=myserver.key

mkdir -p ${STORAGE_DIR} ${DATA_DIR} ${AUTH_DIR} ${CERTS_DIR}

# Copy the certs to the registry directory.
if [[ ! -e ../gen-certs/${TLS_CERT} ]]; then
    echo "run gen-cert.sh first"
    exit 1
fi
cp ../gen-certs/${TLS_CERT} ${CERTS_DIR}
cp ../gen-certs/${TLS_KEY} ${CERTS_DIR}

# Create users/passwords:
(set -x
htpasswd -bBc ${AUTH_DIR}/htpasswd redhat redhat)
cp htpasswd ${AUTH_DIR}

# If a registry is running, stop it.
set +e
podman ps -a --filter=name=${NAME} | grep -q ${NAME}
r=$?
set -e

if [ $r == 0 ]; then
    echo "Registry container exists, recreating."
    (set -x
    podman rm -f ${NAME})
fi

# Insecure version
# podman run --name ${NAME} -p ${LOCAL_PORT}:5000 -v ${DATA_DIR}:/var/lib/registry:z -d --restart=always registry
(set -x
podman create --name ${NAME} -p ${LOCAL_PORT}:5000 -v ${DATA_DIR}:/var/lib/registry:z \
--restart=always -v ${AUTH_DIR}:/auth:z -e "REGISTRY_AUTH=htpasswd" -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
-e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd -v ${CERTS_DIR}:/certs:z \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/${TLS_CERT} \
-e REGISTRY_HTTP_TLS_KEY=/certs/${TLS_KEY} ${IMAGE})

# Helpful commands for debugging.
#
# echo "curl --cacert /storage/registry/certs/domain.crt --user redhat https://ip-172-31-40-75.ec2.internal:5000/v2/_catalog"
# echo "curl localhost:${LOCAL_PORT}/v2/_catalog"
# echo "Edit /etc/containers/registries.conf, restart docker then login"
# echo "podman login https://`hostname`:5000"
#login -u redhat -p redhat ip-172-31-38-186.ec2.internal:5000
#podman login -u redhat -p redhat --cert-dir=/home/ec2-user/storage/registry/certs ip-172-31-38-186.ec2.internal:5000
#podman push ip-172-31-38-186.ec2.internal:5000/registry
#podman push --cert-dir=/home/ec2-user/storage/registry/certs ip-172-31-38-186.ec2.internal:5000/registry
# echo "podman login -u user -p password https://<hostname>:5000"
