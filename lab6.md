## SELinux and Containers

### Overview

In this section, we’ll cover the basics of SELinux and containers. SELinux policy prevents a lot of break out situations where the other security mechanisms fail. By default, Docker processes are labeled with **svirt_lxc_net_t** and they are prevented from doing (almost) all SELinux operations.  But processes within containers do not know that they are running within a container.  SELinux-aware applications are going to attempt to do SELinux operations, especially if they are running as root. With SELinux on Docker, we write a policy that says that the container process running as **svirt_lxc_net_t** can only read/write files with the **svirt_sandbox_file_t** label.

#### !Namespaced

Since we do not want  these SELinux aware apps failing,  it was decided to make libselinux lie to the container processes. The libselinux library checks if **/sys/fs/selinux** is mounted onto the system and whether it is mounted read/write. If **/sys/fs/selinux** is not mounted read/write, libselinux will report to calling applications that SELinux is disabled.  

To demonstrate this, run the following command on {{SERVER_0}} which attempts to execute an selinux operation in a container. It should fail since it tries to return the selinux context of the container.

~~~shell
# docker run --rm rhel7 id -Z

id: --context (-Z) works only on an SELinux-enabled kernel
~~~

With containers, we don't mount these file systems by default or we mount them read/only causing libselinux to report that it is disabled. Now run a container that mounts a host directory in read-only mode. 

Try the following example.

~~~shell
# docker run --rm -v /sys/fs/selinux:/sys/fs/selinux:ro rhel7 id -Z

id: --context (-Z) works only on an SELinux-enabled kernel
~~~

Finally, run a container that mounts the **/sys/fs/selinux** directory as read/write. The expected selinux label should be printed to standard output.

~~~shell
# docker run --rm -v /sys/fs/selinux:/sys/fs/selinux rhel7 id -Z

system_u:system_r:svirt_lxc_net_t:s0:c374,c1019
~~~

#### Bind Mounts

Bind mounts alllow a container to mount a directory on the host for general application usage. This lab will help you understand how selinux behaves on different scenarioes. On {{SERVER_0}}, create the following directories.

~~~shell
# mkdir /data /shared /private
~~~

Run bash in a rhel7 container and volume mount the /data directory on {{SERVER_0}} to the /data directory in the container’s file system. Once the container is running, verify the volume mount and try to list the contents of /data and the files.


~~~shell
# docker run --rm -it -v /data:/data rhel7 bash

[container_id /]# df
[container_id /]# ls /data
~~~

Notice the bash prompt changes when you enter the container’s namespace. Did the mount succeed? How can you check?

Now try to create a file in the /data directory? The command should fail even though the container ran as root.

~~~
[container_id /]# date > /data/date.txt
~~~

Can you examine the /data directory? How would you troubleshoot this issue? To get started, yum install setroubleshootd

Try running sealert -a /var/log/audit/audit.log > /tmp/my-selinux-error-solutions.txt on rhserver0 then enter the container and try creating a file in /data as did you before. The sealert tool with analyze the audit.log and reveal some clues about the problem. Have a look at the /tmp/my-selinux-error-solutions.txt to find out more.


Open a second terminal on {{SERVER_0}} and examine the selinux labels on the host.

~~~
# ls -dZ /data
~~~

Find the selinux context of bash in the container.

~~~
# ps -eZ | grep bash
~~~

Find the selinux file context associated with containers.

~~~
# semanage fcontext --list | grep svirt

/var/lib/kubelet(/.*)?              all files          system_u:object_r:svirt_sandbox_file_t:s0 
/var/lib/docker/vfs(/.*)?           all files          system_u:object_r:svirt_sandbox_file_t:s0
~~~

Change the context of /data/file2 to match the container’s context.

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

Now let Docker create the SELinux labels. Repeat the scenario above but instead add the :Z option for the bind mount the /private directory then try to create a file in the /private directory from the container’s namespace.

~~~
# docker run -d --name sleepy -v /private:/private:Z rhel7 sleep 9999
~~~

Note the addition of a unique Multi-Category Security  (MCS) label to the directory. SELinux takes advantage of MCS separation to ensure that the processes running in the container can only write to svirt_sandbox_file_t files with the same MCS Label s0.

~~~
# ls -dZ /private
~~~

#### Shared Mounts

Repeat the scenario above but instead add the :z option for the bind mount then try to create a file in the /shared directory from the container’s namespace. First stop and remove the sleepy container from the previous exercise.

~~~
# docker rm -f sleepy
# docker run -d --name sleepy -v /shared:/shared:z rhel7 sleep 9999
~~~

On rhserver0, notice the SELinux label on the shared directory.

~~~
# ls -dZ /shared
~~~

#### Read-Only Containers

Imagine a scenario where an application gets compromised. The first thing the bad guy wants to do is to write an exploit into the application, so that the next time the application starts up, it starts up with the exploit in place. If the container was read-only it would prevent leaving a backdoor in place and be forced to start the cycle from the beginning.

Docker added a read-only feature but it presents challenges since many applications need to write to temporary directories like /run or /tmp and when these directories are read-only, the apps fail. Red Hat’s approach leverages tmpfs. It's a nice solution to this problem because it eliminates data exposure on the host. As a best practice, run all applications in production with this mode. 

Run a read-only container and specify a few writable file systems using the --tmpfs option.

~~~shell  
# docker run --rm -ti --name test --read-only --tmpfs /run --tmpfs /tmp rhel7 bash
~~~

Now, try to the following. What fails and what succeeds? Why?

~~~
[container_id /]# mkdir /newdir
[container_id /]# mkdir /run/newdir
~~~









