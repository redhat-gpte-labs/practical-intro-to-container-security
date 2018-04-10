## Image Trust and Signing

#### Image signing configuration

Start by editing ```/etc/sysconfig/docker``` and set **--signature-verification=true** then restart the docker service.

~~~shell
# systemctl restart docker
~~~

Next, create a set of gpg keys on {{SERVER_0}}. In case you're interested, the ```rngd``` program feeds random numbers to the kernel’s entropy pool and will speed up the key generation process.

~~~shell
# yum -y install rng-tools
# rngd -r /dev/urandom 
# gpg --gen-key
~~~

#### Image signing

![Image Encryption]({% image_path encrypt.png %})
Use the ```atomic``` command to sign an image on rhserver0 with your private key and push it to the rhserver1 registry. Use the gpg-key name or email and don’t forget the image tag! Use root/redhat for the registry login credentials. When prompted, the passphrase is redhat.

~~~shell
# gpg2 --list-keys
# atomic sign --sign-by=<key-name or email> --gnupghome /root/.gnupg rhserver1.example.com:5000/rhel7:latest
# atomic push rhserver1.example.com:5000/rhel7:latest

Registry username: root
Registry password: 
Copying blob sha256:e9fb3906049428130d8fc22e715dc6665306ebbf483290dd139be5d7457d9749
 196.50 MB / 196.50 MB [=================================================] 1m10s
Copying blob sha256:1b0bb3f6ad7e8dbdc1d19cf782dc06227de1d95a5d075efb592196a509e6e3a9
 10.00 KB / 10.00 KB [======================================================] 0s
Copying config sha256:d01d4f01d3c4263a3adf535152c633a9ecfd37cdc262015867115028b1b874a8
 0 B / 6.24 KB [------------------------------------------------------------] 0s
Writing manifest to image destination
Signing manifest
Storing signatures 
~~~

Confirm the claim signature was created.

~~~shell
# ls -R /var/lib/atomic/sigstore

/var/lib/atomic/sigstore:
rhel7@sha256=ffc945db45112eaccffabd760c3b09bccd58a27a455a39105f0b0df6295f60e7

/var/lib/atomic/sigstore/rhel7@sha256=ffc945db45112eaccffabd760c3b09bccd58a27a455a39105f0b0df6295f60e7:
signature-1
~~~

NOTE: The signature and push may be done in a single command.

~~~shell
# atomic push --sign-by=<key-name or email> --gnupghome /root/.gnupg rhserver1.example.com:5000/rhel7:latest
~~~

#### Pulling signed images

![Image Decryption]({% image_path decrypt.png %})

In this lab we’ll configure the container host’s trust policy so that it allows only signed images to be pulled from a trusted registry on {{SERVER_1}}. Start by examining the current trust policy then create a default policy that rejects all image pulls.

~~~shell
# atomic trust show

* (default)                         accept                               

# atomic trust default reject
# atomic trust show

* (default)                         reject                               

~~~

First, test that image pulls are rejected by default.

~~~shell
# docker pull rhserver1.example.com:5000/rhel7:latest

Trying to pull repository rhserver1.example.com:5000/rhel7 ... 
rhserver1.example.com:5000/rhel7:latest isn't allowed: Running image docker://rhserver1.example.com:5000/rhel7:latest is rejected by policy.

~~~

Next, create policy to trust signed images from the registry on {{SERVER_1}}. Verify the trust you set up requires a signed image.

~~~shell
# gpg2 --list-keys
# atomic trust add rhserver1.example.com:5000 --sigstoretype=local --sigstore=/var/lib/atomic/sigstore --pubkeys=<gpg-keyname>

# atomic trust show

* (default)                         reject                               
rhserver1.example.com:5000          signed
~~~

Now try to pull the image from the trusted registry {{SERVER_1}} and it should succeed.

~~~shell
# docker pull rhserver1.example.com:5000/rhel7:latest
~~~
