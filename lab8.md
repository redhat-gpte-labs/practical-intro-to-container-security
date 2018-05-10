## Image Trust and Signing

#### Image signing configuration

Start by editing ```/etc/sysconfig/docker``` and set ```--signature-verification=true``` then restart the docker service.

~~~shell
# systemctl restart docker
~~~

Confirm the system has enough entropy to quickly generate gpg keys.

~~~shell
# cat /proc/sys/kernel/random/entropy_avail
22
~~~

If the value returned is < 3000, run the following commands. The ```rngd``` program feeds random numbers to the kernel’s entropy pool 
and will speed up the key generation process.

~~~shell
# yum -y install rng-tools
# rngd -r /dev/urandom
~~~

You can safely ignore the following message.

~~~shell
Failed to init entropy source 1: TPM RNG Device
Failed to init entropy source 2: Intel RDRAND Instruction RNG
~~~

Confirm the entropy pool is now > 3000.

~~~shell
# ps -ef | grep rngd
root      2079     1  0 17:41 ?        00:00:00 rngd -r /dev/urandom

# cat /proc/sys/kernel/random/entropy_avail
3102
~~~

Next, create a set of gpg keys on {{SERVER_0}}. Accept the defaults and provide a key-name, email, comments 
and a passphrase that is easy to remember like "redhat".

~~~shell
# gpg2 --gen-key
...
...
...
gpg: checking the trustdb
gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
pub   2048R/5B38FA8F 2018-04-11
      Key fingerprint = 2F44 55F9 1E0F F6C2 6D11  9A16 D384 7FF5 5B38 FA8F
uid                  summit (comment) <dog@dogs.net>
sub   2048R/9BABEB83 2018-04-11
~~~

#### Image signing

![Image Encryption]({% image_path encrypt.png %})
Use the ```atomic``` command to sign an image on rhserver0 with your private key and push it to the rhserver1 registry. Use the gpg-key name or email and don’t forget the image tag! Use root/redhat for the registry login credentials. When prompted, the passphrase is redhat.

Confirm you have an image with the proper tag.

~~~shell
# docker images
REPOSITORY                      TAG                 IMAGE ID            CREATED             SIZE
rhserver1.example.com:5000/rhel7   latest              d01d4f01d3c4        2 months ago        196 MB
~~~

Now create the signature and push it to the registry on {{SERVER_1}}.

~~~shell
# gpg2 --list-keys
/root/.gnupg/pubring.gpg
------------------------
pub   2048R/5B38FA8F 2018-04-11
uid                  summit (comment) <dog@dogs.net>
sub   2048R/9BABEB83 2018-04-11

# atomic sign --sign-by=dog@dogs.net --gnupghome=/root/.gnupg rhserver1.example.com:5000/rhel7:latest
Created: /var/lib/atomic/sigstore/rhel7@sha256=ffc945db45112eaccffabd760c3b09bccd58a27a455a39105f0b0df6295f60e7/signature-1

# atomic push -u root -p redhat rhserver1.example.com:5000/rhel7:latest

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

NOTE: The signature and push may be done with a single ```atomic``` command.

~~~shell
# atomic push --sign-by=dog@dogs.net --gnupghome /root/.gnupg -u root -p redhat rhserver1.example.com:5000/rhel7:latest
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

Next, create policy to trust signed images from the registry on {{SERVER_1}}. The  ```--sigstore`` argument is used to locate the signature when the image is pulled.

~~~shell
# gpg2 --list-keys
# atomic trust add rhserver1.example.com:5000 --sigstore=file:///var/lib/atomic/sigstore --pubkeys=dog@dogs.net

# atomic trust show

* (default)                         reject                               
rhserver1.example.com:5000          signed dog@dogs.net
~~~

Now try to pull the image from the trusted registry {{SERVER_1}} and it should succeed.

~~~shell
# docker pull rhserver1.example.com:5000/rhel7:latest

Trying to pull repository rhserver1.example.com:5000/rhel7 ... 
sha256:ffc945db45112eaccffabd760c3b09bccd58a27a455a39105f0b0df6295f60e7: Pulling from rhserver1.example.com:5000/rhel7
Digest: sha256:ffc945db45112eaccffabd760c3b09bccd58a27a455a39105f0b0df6295f60e7
Status: Downloaded newer image for rhserver1.example.com:5000/rhel7:latest
~~~

NOTE: The ```atomic``` command can also pull images.

~~~shell
# atomic pull rhserver1.example.com:5000/rhel7:latest

Pulling rhserver1.example.com:5000/rhel7:latest ...
Copying blob sha256:9a32f102e6778e4b3c677f1f93fa121808006d3c9e002237677248de9acb9589
 71.40 MB / 71.40 MB [======================================================] 2s
Copying blob sha256:b8aa42cec17a56aea47fa45bd8029d1e877b21213017e849a839aadba9e1486c
 1.21 KB / 1.21 KB [========================================================] 0s
Copying config sha256:d01d4f01d3c4263a3adf535152c633a9ecfd37cdc262015867115028b1b874a8
 6.24 KB / 6.24 KB [========================================================] 0s
Writing manifest to image destination
Storing signatures
~~~

Extra Credit.

Create a trust policy that only allows images from Red Hat's Container Catalog to be pulled.

First, try a pull and it should fail.

~~~shell
# docker pull registry.access.redhat.com/rhel-atomic
Using default tag: latest
Trying to pull repository registry.access.redhat.com/rhel-atomic ... 
registry.access.redhat.com/rhel-atomic:latest isn't allowed: Running image docker://registry.access.redhat.com/rhel-atomic:latest is rejected by policy.
~~~

Like you did above, add a trust policy for registry.access.redhat.com using Red Hat's public key and signature.

~~~shell
# atomic trust add registry.access.redhat.com --pubkeys /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release --sigstore https://access.redhat.com/webassets/docker/content/sigstore

# atomic trust show

* (default)                         reject                               
registry.access.redhat.com          signed security@redhat.com,security@redhat.com
rhserver1.example.com:5000          signed dog@dogs.net    

# docker pull registry.access.redhat.com/rhel-atomic

Using default tag: latest
Trying to pull repository registry.access.redhat.com/rhel-atomic ... 
sha256:4de1899892c07c1e16b0f67dc228b6fa151e799c2529fa17ce69a0997635be77: Pulling from registry.access.redhat.com/rhel-atomic
ef0ccce8592e: Pull complete 
5694480effa7: Pull complete 
Digest: sha256:4de1899892c07c1e16b0f67dc228b6fa151e799c2529fa17ce69a0997635be77
Status: Downloaded newer image for registry.access.redhat.com/rhel-atomic:latest              
~~~