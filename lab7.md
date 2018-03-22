## Inspecting Content

Docker images can easily be pulled from any public registry and run on a container host but is this good practice? Do we trust this image and what are its contents? A better approach would be to inspect and scan the image first. The atomic command that ships with RHEL7 Server provides complete scanning functionality for images.

#### Atomic diff

The ```atomic``` command can help understand the difference between two images or an image and a running container. Run the rhel7 image and connect to it's namespace with bash. Then make some change like creating a file or something.

~~~shell
# atomic diff --help
# man atomic-diff

# docker run --rm -it --name my_container rhel7 bash
[container_id /]# date > /var/tmp/date.txt
~~~

Now, open a new terminal window, ssh into rhserver0 and run atomic diff to see the differences between the rhel7 image and the running container. 

~~~shell
# atomic diff rhel7 my_container
~~~

Atomic will report a list of differences between the two file systems. The /var/tmp/date.txt file should appear in the report.

Exit the container namespace when you're finished.

~~~shell
[container_id /]# exit
~~~

#### Atomic mount

Next we’ll use the atomic command to inspect a container’s filesystem by mounting it to the host.

~~~shell
# mkdir /mnt/image
# atomic mount rhel7 /mnt/image
# cat /mnt/image/etc/redhat-release
~~~

Unmount the container from the previous exercise and try mounting an image from a remote registry. 

~~~shell
# atomic umount /mnt/image
# atomic mount rhserver1.example.com:5000/mystery /mnt/image
# ls /mnt/image/etc
~~~

How might you search a container for all programs that are owned by root and have the SETUID bit set? Sound like a good idea for a custom container scanner?
~~~shell
# find /mnt/image -user root -perm -4000 -exec ls -ldb {} \;
~~~
Unmount the container when you're finished.

~~~shell
# atomic umount /mnt/image
~~~

#### Live Shared mount

Use atomic to live mount a running a container. This option allows the user to modify the container's contents as it runs or updates the container's software without rebuilding the container.

~~~shell
# docker run --rm --name sleepy rhel7 sleep 9999
~~~

Open a second window and mount the running container’s file system from the host.

~~~shell
# mkdir /mnt/live
# atomic mount --live sleepy /mnt/live
# date > /mnt/live/usr/tmp/date.txt
~~~

Use atomic to live mount a running a container. This option allows the user to modify the container's contents as it runs or updates the container's software without rebuilding the container.

~~~shell
# docker run --rm --name sleepy rhel7 sleep 9999
~~~

Open a second window and mount the running container’s file system from the host.

~~~shell
# mkdir /mnt/live
# atomic mount --live sleepy /mnt/live
# date > /mnt/live/usr/tmp/date.txt
~~~

This option mounts a container with a shared SELinux label.

~~~shell
# atomic mount --shared sleepy /mnt/live
# ls -dZ /mnt/live
~~~

Compare the SELinux label of the mount point to the live mount in the step above then unmount the container. It should not have an SELInux MCS label.

~~~shell
# atomic umount /mnt/live
~~~

Exit from the container namespace.

~~~shell
[container_id /] # exit
~~~

#### Atomic images

Have a look at the atomic-images man page to read about it’s useful commands then experiment by inspecting an image from a remote registry. Below is an example to get you started.

~~~shell
# atomic images version rhserver1.example.com:5000/mystery
~~~

#### Inspecting images with Skopeo

Skopeo is an additional tool that can perform image operations on remote registries. Run the skopeo command from rhserver0 and inspect one of the images that you pushed to the registry on rhserver1.

~~~shell
# skopeo --tls-verify=false inspect docker://<remote-registry-host:port>/<image>
~~~

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






