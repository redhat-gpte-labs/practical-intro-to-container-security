## New Stuff

### Getting started with CRI-O

CRI-O is an open source implementation of the [Open Container Initiative.](https://github.com/opencontainers/runtime-spec) To become familiar with the tools based on the CRI-O spec, follow
this simple example which is based on the ```run-spec (1)``` man page. For further information, have a look at the documentation for [running containers without Docker.](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/managing_containers/finding_running_and_building_containers_without_docker)

##### Migrating a container image from Docker to CRI-O

A CRI-O container consists of a directory that contains a *spec* file and a *root* file system. During this
exercise, you will use ```runc``` to create a *spec* file and export a file system from an existing Docker container. Then 
you will modify the *spec* file to change the container's capabilities. 

Perform this lab on *{{SERVER_0}}*.

To get started, install the ```runc``` package.

~~~shell
# yum -y install runc
~~~

Create a directory for your work.

~~~shell 
# mkdir lab11
# cd lab11
~~~

Now use Docker to export the file system of a newly created rhel7 container.

~~~shell
# docker export $(docker create rhel7) > rhel7-rootfs.tar
~~~

Create a *rootfs* directory then use ```tar``` to extract the file system into that directory.

~~~shell
# mkdir rootfs
# tar -C rootfs -xf rhel7-rootfs.tar
~~~

Use the ```runc``` command to create a spec file template. Have a look at the contents of the ```config.json``` file that was created.

~~~shell
# runc spec
~~~

Now it time to run the container.

~~~shell
# runc run mycontainer
~~~

Print the capabilities.

~~~shell
sh-4.2# capsh --print
~~~

~~~shell
Current: = cap_kill,cap_net_bind_service,cap_audit_write+eip
Bounding set =cap_kill,cap_net_bind_service,cap_audit_write
Securebits: 00/0x0/1'b0
 secure-noroot: no (unlocked)
 secure-no-suid-fixup: no (unlocked)
 secure-keep-caps: no (unlocked)
uid=0(root)
gid=0(root)
groups=
~~~

Try to set the date backwards. It should fail since it lacks the necessary capabilities.

~~~shell
sh-4.2# moment=$(date) && date -s "$moment"
date: cannot set date: Operation not permitted
Tue May  8 00:58:00 UTC 2018
~~~

Exit the container.

~~~shell
sh-4.2# exit
~~~

Use what you learned in the isolation lab and make the necessary changes to the spec file to add the ```CAP_SYS_TIME``` capability.

Run the container again. 

~~~shell
# runc run mycontainer
~~~

Confirm the capabilities were updated.

~~~shell
sh-4.2# capsh --print
~~~

~~~shell
Current: = cap_kill,cap_net_bind_service,cap_sys_time,cap_audit_write+eip
Bounding set =cap_kill,cap_net_bind_service,cap_sys_time,cap_audit_write
Securebits: 00/0x0/1'b0
 secure-noroot: no (unlocked)
 secure-no-suid-fixup: no (unlocked)
 secure-keep-caps: no (unlocked)
uid=0(root)
gid=0(root)
groups=
~~~

Run the container and observe the output.

~~~shell
# runc run mycontainer
~~~

Now try to change the date backwards a few seconds. It should suceed.

~~~shell
sh-4.2# moment=$(date) && date -s "$moment"
Tue May  8 01:29:43 UTC 2018
~~~

