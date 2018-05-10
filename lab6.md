## SELinux and Containers

### Overview

In this section, we’ll cover the basics of SELinux and containers. SELinux policy prevents a lot of break out situations where the other security mechanisms fail. By default, Docker processes are labeled with ```svirt_lxc_net_t``` and they are prevented from doing (almost) all SELinux operations.  But processes within containers do not know that they are running within a container.  SELinux-aware applications are going to attempt to do SELinux operations, especially if they are running as root. With SELinux on Docker, we write a policy that says that the container process running as ```svirt_lxc_net_t``` can only read/write files with the ```svirt_sandbox_file_t``` or ```container_file_t``` label.

#### !Namespaced

SELinux is not namespaced. Since we do not want SELinux aware applications failing when they run in containers, it was decided to make **libselinux** appear that SELinux is running to the container processes. In doing so, the **libselinux** library makes the following checks:

 * The ```/sys/fs/selinux``` directory is mounted read/write. 
 * The ```/etc/selinux/config``` file exists.

 If both of these conditions are not met, **libselinux** will report to calling applications that SELinux is disabled.  

##### Exercise 

To demonstrate this, confirm the following commands on {{SERVER_0}} produce the expected output.

Start by running a container that mounts ```/sys/fs/selinux``` as read-only then runs a command that requires an SELinux enabled kernel.

~~~shell
# docker run --rm -v /sys/fs/selinux:/sys/fs/selinux:ro rhel7 id -Z
id: --context (-Z) works only on an SELinux-enabled kernel
~~~

Next, run a container that mounts the ```/sys/fs/selinux``` directory as read/write. Confirm the expected SELinux label is reported.

~~~shell
# docker run --rm -it -v /sys/fs/selinux:/sys/fs/selinux:rw rhel7 bash 

[root@container-id \]# id -Z
id: --context (-Z) works only on an SELinux-enabled kernel

[root@container-id \]# touch /etc/selinux/config
[root@container-id \]# id -Z
system_u:system_r:svirt_lxc_net_t:s0:c553,c697

[root@container-id \]#  exit
~~~

#### Bind Mounts

Bind mounts allow a container to mount a directory on the host for general application usage. This lab will help you understand how selinux behaves on different scenarios. On {{SERVER_0}}, create the following directories.

~~~shell
# mkdir /data /shared /private
~~~

Run bash in a rhel7 container and volume mount the ```/data``` directory on {{SERVER_0}} to the ```/data``` directory in the container’s file system. Once the container is running, verify the volume mount and try to list the contents of ```/data```. Notice the bash prompt changes when you enter the container’s namespace. Did the mount succeed? How can you check? Try to create a file in the ```/data``` directory? The command should fail even though the container ran as root.  

~~~shell
# docker run --rm -it -v /data:/data rhel7 bash
[container_id /]# df /data

Filesystem     1K-blocks    Used Available Use% Mounted on
/dev/vda1       52417516 1820900  50596616   4% /data

[container_id /]# ls /data

ls: cannot open directory /data: Permission denied

[container_id /]# date > /data/date.txt

bash: /data/date.txt: Permission denied

[container_id /]# exit
~~~

How would you troubleshoot this issue? To get started, install the selinux troubleshooter on {{SERVER_0}}.

~~~shell
# yum -y install setroubleshoot
~~~ 

The ```sealert``` tool will analyze and decode the ```audit.log``` and make suggestions on how to remedy the problem.

~~~shell
# sealert -a /var/log/audit/audit.log > /tmp/my-selinux-error-solutions.txt
# cat /tmp/my-selinux-error-solutions.txt

found 1 alerts in /var/log/audit/audit.log
--------------------------------------------------------------------------------

SELinux is preventing /usr/bin/bash from write access on the directory data.

*****  Plugin catchall_labels (83.8 confidence) suggests   *******************

If you want to allow bash to have write access on the data directory
Then you need to change the label on data
Do
# semanage fcontext -a -t FILE_TYPE 'data'
where FILE_TYPE is one of the following: container_file_t, container_var_lib_t, nfs_t, svirt_home_t, tmpfs_t, virt_home_t.
Then execute:
restorecon -v 'data'
~~~

Examine the SELinux label of ```/data``` and note the type is ```default_t```.

~~~shell
# ls -dZ /data

drwxr-xr-x. root root unconfined_u:object_r:default_t:s0 /data
~~~

So let's take the suggestion of changing the label type of the ```/data``` directory to ```virt_home_t```.

~~~shell
# chcon -R --type=svirt_home_t /data
# ls -dZ /data

drwxr-xr-x. root root unconfined_u:object_r:svirt_home_t:s0 /data
~~~

Now run the container and try to write into ```/data``` as you did above. It should succeed.

~~~shell
# docker run --rm -it -v /data:/data rhel7 bash
[root@a72bd00b3356 /]# ls /data
[root@a72bd00b3356 /]# date > /data/date.txt
[root@a72bd00b3356 /]# exit
exit
~~~

#### Private Mounts

Now let Docker create the SELinux labels. To change a label in the container context, you can add either of two suffixes ```:z``` or ```:Z``` to the volume mount. These suffixes tell Docker to relabel file objects on the shared volumes. The ```:Z``` option tells Docker to label the content with a private unshared label. 

Repeat the scenario above but instead add the ```:Z``` option to bind mount the ```/private``` directory then try to create a file in the ```/private``` directory from the container’s namespace.

First examine the label.

~~~shell
# ls -dZ /private

drwxr-xr-x. root root unconfined_u:object_r:default_t:s0 /shared
~~~

Now run a container in the background that bind mounts ```/private``` using ```:Z```.

~~~shell
# docker run -d --name sleepy -v /private:/private:Z rhel7 sleep 9999

07c5aebd894182119668feddf4849d1f75bc5a81a84db222169e5f9b9efa625c

# docker ps

CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
07c5aebd8941        rhel7               "sleep 9999"        4 seconds ago       Up 3 seconds                            sleepy
~~~

Note the addition of a unique Multi-Category Security (MCS) label (```c788,c986```) to the directory. SELinux takes advantage of MCS separation to ensure that the processes running in the container can only write to files with the same MCS Label.

~~~shell
# ls -dZ /private

drwxr-xr-x. root root system_u:object_r:container_file_t:s0:c788,c986 /private
~~~

#### Shared Mounts

Repeat the scenario above but instead add the ```:z``` option for the bind mount then try to create a file in the ```/shared``` directory from the container’s namespace. First stop and remove the sleepy container from the previous exercise. The ```:z``` option tells Docker that two containers share the volume content. As a result, Docker labels the content with a shared content label. Shared volume labels allow all containers to read/write content.

First examine the label.

~~~shell
# ls -dZ /shared
drwxr-xr-x. root root unconfined_u:object_r:default_t:s0 /shared
~~~

Now run a container in the background that bind mounts ```/shared``` using ```:z```.

~~~shell
# docker rm -f sleepy
# docker run -d --name sleepy -v /shared:/shared:z rhel7 sleep 9999
~~~

On {{SERVER_0}}, notice the SELinux label on the shared directory.

~~~shell
# ls -dZ /shared

drwxr-xr-x. root root system_u:object_r:container_file_t:s0 /shared
~~~

Cleanup.

~~~shell
# docker rm -f sleepy
~~~

#### Read-Only Containers

Imagine a scenario where an application gets compromised. The first thing the bad guy wants to do is to write an exploit into the application, so that the next time the application starts up, it starts up with the exploit in place. If the container was read-only it would prevent leaving a backdoor in place and be forced to start the cycle from the beginning.

Docker added a read-only feature but it presents challenges since many applications need to write to temporary directories like ```/run``` or ```/tmp``` and when these directories are read-only, the apps fail. Red Hat’s approach leverages ```tmpfs```. It's a nice solution to this problem because it eliminates data exposure on the host. As a best practice, run all applications in production with this mode. 

Run a read-only container and specify a few writable file systems using the ```--tmpfs``` option.

~~~shell  
# docker run --rm -ti --name test --read-only --tmpfs /run --tmpfs /tmp rhel7 bash
~~~

Now, try to the following. What fails and what succeeds? Why?

~~~shell
[container_id /]# mkdir /newdir

mkdir: cannot create directory '/newdir': Read-only file system

[container_id /]# mkdir /run/newdir
[container_id /]# exit

exit
~~~

We've covered a lot of ground here on Dan's favorite topic. You should feel good.







