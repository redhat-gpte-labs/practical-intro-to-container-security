## Image Trust and Signing

#### Image signing configuration

Edit /etc/sysconfig/docker and set --signature-verification=true then restart the docker service.

~~~shell
# systemctl restart docker
~~~

A pair of gpg keys have been created for you. However, if you’d like to create your own set of gpg keys, perform the following on rhserver0. In case you're interested, the rngd program feeds random numbers to the kernel’s entropy pool and will speed up the key generation process.

~~~shell
# yum install rng-tools
# rngd -r /dev/urandom --verbose
# gpg --gen-key
~~~

#### Image signing

![Image Encryption]({% image_path encrypt.png %})
Use the ```atomic``` command to sign an image on rhserver0 with your private key and push it to the rhserver1 registry. Use the gpg-key name or email and don’t forget the image tag! Use root/redhat for the login credentials. When prompted, the passphrase is redhat.

~~~shell
# gpg --list-keys
# atomic push --sign-by <gpg-key> <registry/image:tag>
~~~

Confirm the claim signature was created.

~~~shell
# ls -R /var/lib/atomic/sigstore
~~~

#### Pulling signed images

![Image Decryption]({% image_path decrypt.png %})

In this lab we’ll configure the container host’s trust policy so that it allows only signed images to be pulled from a trusted registry on {{SERVER_1}}. Start by examining the current trust policy then create a default policy that rejects all image pulls.

~~~shell
# atomic trust show
# atomic trust default reject
# atomic trust show
~~~

First, test that image pulls are rejected by default.

~~~shell
# docker pull rhserver1.example.com:5000/mystery:latest
...image:tag is rejected by policy
~~~

Next, create policy to trust signed images from the registry on rhserver1. Verify the trust you set up requires a signed image.

~~~shell
# gpg --list-keys
# gpg --export <key> > /root/root.pub
# atomic trust add rhserver1.example.com:5000 \ --sigstore=file:///var/lib/atomic/sigstore --pubkeys=/root/root.pub
# atomic trust show

* (default)                         reject                               
rhserver1.example.com:5000          signed
~~~

Now try the pull the signed image from {{SERVER_1}} again and it should succeed.

~~~shell
# docker pull rhserver1.example.com:5000/mystery:latest
~~~
