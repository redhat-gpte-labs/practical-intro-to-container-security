## SELinux and Containers

### Overview

In this section, we’ll cover the basics of SELinux and containers. SELinux policy prevents a lot of break out situations where the other security mechanisms fail. By default, Docker processes are labeled with ```svirt_lxc_net_t``` and they are prevented from doing (almost) all SELinux operations.  But processes within containers do not know that they are running within a container.  SELinux-aware applications are going to attempt to do SELinux operations, especially if they are running as root. With SELinux on Docker, we write a policy that says that the container process running as ```svirt_lxc_net_t``` can only read/write files with the ```svirt_sandbox_file_t``` label.

#### !Namespaced

SELinux is not namespaced. Since we do not want SELinux aware applications failing when they run in containers, it was decided to make **libselinux** appear that SELinux is running to the container processes. In doing so, the **libselinux** library makes the following checks:

 * The ```/sys/fs/selinux``` directory is mounted read/write. 
 * The ```/etc/selinux/config``` file exists.

 If both of these conditions are not met, **libselinux** will report to calling applications that SELinux is disabled.  

##### Exercise 

To demonstrate this, confirm the following commands on {{SERVER_0}} produce the expected output.

Start by running a container that mounts ```/sys/fs/selinux``` as read-only then runs a command that requires an SELInux enabled kernel.

~~~shell
# docker run --rm -v /sys/fs/selinux:/sys/fs/selinux:ro rhel7 id -Z
id: --context (-Z) works only on an SELinux-enabled kernel
~~~

Next, run a container that mounts the ```/sys/fs/selinux``` directory as read/write. Confirm the expected SELinux label is reported.

~~~shell
# docker run --rm -v /sys/fs/selinux:/sys/fs/selinux:rw rhel7 bash 
[root@container-id \]# id -Z
id: --context (-Z) works only on an SELinux-enabled kernel
[root@container-id \]# touch /etc/selinux/config
[root@container-id \]# id -Z
system_u:system_r:svirt_lxc_net_t:s0:c553,c697
[root@container-id \]#  exit
~~~

#### Bind Mounts

BOB: This section needs proof reading for accuracy of proper flow, commands and output.

Bind mounts alllow a container to mount a directory on the host for general application usage. This lab will help you understand how selinux behaves on different scenarioes. On {{SERVER_0}}, create the following directories.

~~~shell
# mkdir /data /shared /private
~~~

Run bash in a rhel7 container and volume mount the ```/data``` directory on {{SERVER_0}} to the ```/data``` directory in the container’s file system. Once the container is running, verify the volume mount and try to list the contents of ```/data```.

~~~shell
# docker run --rm -it -v /data:/data rhel7 bash
[container_id /]# df
[container_id /]# ls /data
~~~

Notice the bash prompt changes when you enter the container’s namespace. Did the mount succeed? How can you check?

Now try to create a file in the ```/data``` directory? The command should fail even though the container ran as root.

~~~shell
[container_id /]# date > /data/date.txt
bash: /data/date.txt: Permission denied
~~~

Can you list the ```/data``` directory? How would you troubleshoot this issue? To get started, install the selinux troubleshooter.

~~~shell
# yum -y install setroubleshoot
~~~ 

Try running ```sealert``` on {{SERVER_0}} then enter the container and try creating a file in ```/data``` as did you above. The ```sealert``` tool will analyze the ```audit.log``` and reveal some clues about the problem. Have a look at output file and make note of the source and target SELinux contexts.

~~~shell
# sealert -a /var/log/audit/audit.log > /tmp/my-selinux-error-solutions.txt
# docker run --rm -it -v /data:/data rhel7 bash
[root@rhserver0 ~]# docker run --rm -it -v /data:/data rhel7 bash
[root@a72bd00b3356 /]# date > /data/date.txt
bash: /data/date.txt: Permission denied
[root@a72bd00b3356 /]# exit
exit

# cat /tmp/my-selinux-error-solutions.txt
Local ID                      be4be986-a321-4e89-85cb-80bb3990ce8d

Raw Audit Messages
type=AVC msg=audit(1522186708.438:248): avc:  denied  { write } for  pid=3228 comm="bash" name="data" dev="vda1" ino=54526408 scontext=system_u:system_r:svirt_lxc_net_t:s0:c875,c1023 tcontext=system_u:object_r:root_t:s0 tclass=dir

type=SYSCALL msg=audit(1522186708.438:248): arch=x86_64 syscall=open success=no exit=EACCES a0=100b080 a1=241 a2=1b6 a3=0 items=0 ppid=3195 pid=3228 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4294967295 comm=bash exe=/usr/bin/bash subj=system_u:system_r:svirt_lxc_net_t:s0:c875,c1023 key=(null)

Hash: bash,svirt_lxc_net_t,root_t,dir,write
~~~

Open a second terminal on {{SERVER_0}} and examine the selinux labels on the host.

~~~
# ls -dZ /data
drwxr-xr-x. root root system_u:object_r:root_t:s0      /data
~~~

Find the selinux context of process in the container.

~~~
# docker run --rm -it -v /data:/data rhel7 ps -eZ 
LABEL                             PID TTY          TIME CMD
system_u:system_r:svirt_lxc_net_t:s0:c693,c801 1 ? 00:00:00 ps
~~~

Find the selinux file context associated with containers.

~~~
# semanage fcontext --list | grep svirt

/var/lib/kubelet(/.*)?              all files          system_u:object_r:svirt_sandbox_file_t:s0 
/var/lib/docker/vfs(/.*)?           all files          system_u:object_r:svirt_sandbox_file_t:s0
~~~

Change the context of ```/data/file2``` to match the container’s context.

~~~
# chcon -Rt svirt_sandbox_file_t /data
~~~

Now try to create a file again from the container shell. It should succeed.

~~~
[container_id /]# date > /data/date.txt
~~~

Exit the container.

~~~
[container_id /]# exit
~~~

#### Private Mounts

Now let Docker create the SELinux labels. Repeat the scenario above but instead add the ```:Z``` option for the bind mount the ```/private``` directory then try to create a file in the ```/private``` directory from the container’s namespace.

~~~
# docker run -d --name sleepy -v /private:/private:Z rhel7 sleep 9999
~~~

Note the addition of a unique Multi-Category Security  (MCS) label to the directory. SELinux takes advantage of MCS separation to ensure that the processes running in the container can only write to ```svirt_sandbox_file_t``` files with the same MCS Label s0.

~~~
# ls -dZ /private
~~~

#### Shared Mounts

Repeat the scenario above but instead add the ```:z``` option for the bind mount then try to create a file in the ```/shared``` directory from the container’s namespace. First stop and remove the sleepy container from the previous exercise.

~~~
# docker rm -f sleepy
# docker run -d --name sleepy -v /shared:/shared:z rhel7 sleep 9999
~~~

On {{SERVER_0}}, notice the SELinux label on the shared directory.

~~~
# ls -dZ /shared
~~~

#### Read-Only Containers

Imagine a scenario where an application gets compromised. The first thing the bad guy wants to do is to write an exploit into the application, so that the next time the application starts up, it starts up with the exploit in place. If the container was read-only it would prevent leaving a backdoor in place and be forced to start the cycle from the beginning.

Docker added a read-only feature but it presents challenges since many applications need to write to temporary directories like ```/run``` or ```/tmp``` and when these directories are read-only, the apps fail. Red Hat’s approach leverages tmpfs. It's a nice solution to this problem because it eliminates data exposure on the host. As a best practice, run all applications in production with this mode. 

Run a read-only container and specify a few writable file systems using the ```--tmpfs``` option.

~~~shell  
# docker run --rm -ti --name test --read-only --tmpfs /run --tmpfs /tmp rhel7 bash
~~~

Now, try to the following. What fails and what succeeds? Why?

~~~
[container_id /]# mkdir /newdir
[container_id /]# mkdir /run/newdir
~~~









