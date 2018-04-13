## Inspecting Content

Docker images can easily be pulled from any public registry and run on a container host but is this good practice? Do we trust this image and what are its contents? A better approach would be to inspect and scan the image first. The atomic command that ships with RHEL7 Server provides complete scanning functionality for container images.

#### Atomic diff

The ```atomic``` command can help understand the difference between two images or an image and a running container. Run the rhel7 image and connect to it's namespace with bash. Then make some change like creating a file.

~~~shell
# yum -y install atomic

# docker run --rm -it --name my_container rhel7:latest bash

[container_id /]# date > /var/tmp/date.txt
~~~

Now, open a new terminal window, ssh into rhserver0 and run atomic diff to see the differences between the rhel7 image and the running container. 

~~~shell
# atomic diff rhel7:latest my_container
~~~

Atomic will report a list of differences between the two file systems. The /var/tmp/date.txt file should appear in the report.

~~~shell
Files only in my_container:
     var/tmp/date.txt

Common files that are different: (reason)
     dev (time)
     etc/hostname (time)
     dev/pts (time)
     . (time)
     dev/console (time)
     etc/hosts (time)
     dev/shm (time)
     etc/resolv.conf (time)
     var/tmp (size time)
     etc (time)
     .dockerenv (time)
     etc/mtab (time)
~~~

#### Atomic mount

Next we’ll use the atomic command to inspect a container’s filesystem by mounting it to the host.

~~~shell
# mkdir /mnt/image
# atomic mount rhel7:latest /mnt/image
# cat /mnt/image/etc/redhat-release
~~~

Unmount the container from the previous exercise and try mounting an image from a remote registry. 

~~~shell
# atomic umount /mnt/image
# atomic mount rhserver1.example.com:5000/mystery:latest /mnt/image
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

Use atomic to live mount the file system of a running container. This option allows the user to modify the container's contents as it runs or updates the container's software without rebuilding the container.

Mount the file system of the container you created above and modify the ```date.txt``` file.

~~~shell
# mkdir /mnt/live
# atomic mount --live my_container /mnt/live
# date >> /mnt/live/usr/tmp/date.txt
# cat /mnt/live/var/tmp/date.txt 

Thu Mar 29 19:46:24 UTC 2018
Thu Mar 29 15:51:09 EDT 2018
~~~

#### SELinux labels

The ```--shared``` option mounts a container with a shared SELinux label. Compare the SELinux labels of the two mount points. The ```/mnt/shared``` directory should not have an SELInux MCS label.


~~~shell
# mkdir /mnt/shared
# atomic mount --shared my_container /mnt/shared
# ls -Z /mnt

dr-xr-xr-x. root root system_u:object_r:svirt_sandbox_file_t:s0:c139,c976 live
dr-xr-xr-x. root root system_u:object_r:usr_t:s0       shared
~~~

Clean up.

~~~shell
# atomic umount /mnt/live 
# atomic umount /mnt/shared
~~~

Exit the running container.

~~~shell
[container_id /] # exit
~~~

#### Atomic images

Have a look at the atomic-images man page to read about it’s useful commands then experiment by inspecting an image from local container storage. Below is an example to get you started.

~~~shell
# atomic images info mystery:latest
# atomic images info rhel7:latest
# atomic images verify rhel7:latest
~~~

#### Working with Skopeo

Skopeo is an additional tool that can perform image operations on remote registries. Give the example below a try. What does it do? 

~~~shell
# yum -y install skopeo
# skopeo copy --dest-tls-verify=false docker-daemon:rhel7:latest docker://rhserver1.example.com:5000/rhel7

Getting image source signatures
Copying blob sha256:e9fb3906049428130d8fc22e715dc6665306ebbf483290dd139be5d7457d9749
 196.50 MB / 196.50 MB [=================================================] 1m10s
Copying blob sha256:1b0bb3f6ad7e8dbdc1d19cf782dc06227de1d95a5d075efb592196a509e6e3a9
 10.00 KB / 10.00 KB [======================================================] 0s
Copying config sha256:d01d4f01d3c4263a3adf535152c633a9ecfd37cdc262015867115028b1b874a8
 0 B / 6.24 KB [------------------------------------------------------------] 0s
Writing manifest to image destination
Storing signatures
~~~

Extra Credit

Have a look at the ```skopeo(1)``` man page and expiriment. See if you can copy an image from one registry to another.

Answer below.

~~~shell
# skopeo copy --dest-tls-verify=false --src-tls-verify=false docker://rhserver1.example.com:5000/rhel7 docker://rhserver2.example.com:5000/rhel7

Getting image source signatures
Copying blob sha256:9a32f102e6778e4b3c677f1f93fa121808006d3c9e002237677248de9acb9589
 71.40 MB / 71.40 MB [======================================================] 1s
Copying blob sha256:b8aa42cec17a56aea47fa45bd8029d1e877b21213017e849a839aadba9e1486c
 1.21 KB / 1.21 KB [========================================================] 0s
Copying config sha256:d01d4f01d3c4263a3adf535152c633a9ecfd37cdc262015867115028b1b874a8
 6.24 KB / 6.24 KB [========================================================] 0s
Writing manifest to image destination
Storing signatures
~~~

Inspection

Try the following ```skopeo``` commands to inspect an image.

~~~shell
skopeo inspect --tls-verify=false docker://rhserver1.example.com:5000/rhel7
~~~





