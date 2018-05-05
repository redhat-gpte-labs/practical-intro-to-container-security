## New Stuff

### Getting started with runc

To become familiar with the tools based on the CRI-O spec, follow
this simple example based on the run-spec (1) man page.

First, install the runc package.

~~~shell
# yum -y install runc
~~~

A runc container consists of a directory that contains a *spec* file and a *root* file system.

~~~shell 
mkdir hello
cd hello
docker pull hello-world
docker export $(docker create hello-world) > hello-world.tar
mkdir rootfs
tar -C rootfs -xf hello-world.tar
runc spec
sed -i 's;"sh";"/hello";' config.json
runc run container1
~~~


