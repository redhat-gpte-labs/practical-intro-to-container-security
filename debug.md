# Debugging

## Image signing

~~~shell
/etc/containers/registries.d/default.yaml 

default-docker:

  sigstore-staging: file:///var/lib/containers/sigstore

docker:
  server.summit.lab:
   sigstore: file:///usr/tmp/sigstore/server.summit.lab
   sigstore-staging: file:///usr/tmp/sigstore/server.summit.lab

~~~

~~~shell

mkdir /usr/tmp/sigstore/server.summit.lab

podman tag localhost/rhel-ubi8 server.summit.lab/quayuser/rhel-ubi8

podman login --username=quayuser --password=L36PrivxRB02bqOB9jtZtWiCcMsApOGn server.summit.lab

podman push server.summit.lab/quayuser/rhel-ubi8

gpg2 --quick-gen-key --yes lab-user

gpg2 --export lab-user > /usr/tmp/keys/gpg-pubkey.gpg

podman image sign --sign-by lab-user docker://server.summit.lab/quayuser/rhel-ubi8

ls -R /usr/tmp/sigstore/server.summit.lab

sudo podman image trust set -t reject default

sudo podman image trust set --type signedBy --pubkeysfile /usr/tmp/keys/gpg-pubkey.gpg server.summit.lab

podman image trust show --raw

podman image trust show --raw

{
    "default": [
        {
            "type": "reject"
        }
    ],
    "transports": {
        "docker": {
            "docker.io": [
                {
                    "type": "signedBy",
                    "keyType": "GPGKeys",
                    "keyPath": "/usr/tmp/keys/gpg-pubkey.gpg"
                }
            ],
            "server.summit.lab": [
                {
                    "type": "signedBy",
                    "keyType": "GPGKeys",
                    "keyPath": "/usr/tmp/keys/gpg-pubkey.gpg"
                }
            ]
        },
        "docker-daemon": {
            "": [
                {
                    "type": "insecureAcceptAnything"
                }
            ]
        }
    }
}

podman pull server.summit.lab/quayuser/rhel-ubi8

podman image trust set --type reject docker.io
podman pull docker.io/cirros

Trying to pull docker.io/cirros...Failed
error pulling image "docker.io/cirros": unable to pull docker.io/cirros: unable to pull image: Source image rejected: Running image docker://cirros:latest is rejected by policy.

~~~