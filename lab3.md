## Configuration
During this lab you will configure {{SERVER_1}} **and** {{SERVER_2}} as container registries then configure the container run-time on {{SERVER_0}} to use them. Most of the remaining lab exercises will be performed on {{SERVER_0}}. 

{% if USE_CRI-O == true %}

#### Modified for CRI-O
Use CRI-O

{% else %}

#### Exercise: Registry Configuration

##### Goals 

* Install, start and enable the registry and firewalld services.
* Open tcp firewall port 5000. 
* Use curl to test connectivity to the registry services.

##### Howto

Perform the following on both {{SERVER_1}} **and** {{SERVER_2}}.

~~~shell
# yum -y install docker-distribution firewalld wget
# systemctl start docker-distribution
# systemctl enable docker-distribution
# systemctl start firewalld
# systemctl enable firewalld
# firewall-cmd --add-port 5000/tcp --permanent
# firewall-cmd --reload
~~~
~~~shell
# systemctl status docker-distribution
~~~~
Expected Output:

~~~shell
● docker-distribution.service - v2 Registry server for Docker
   Loaded: loaded (/usr/lib/systemd/system/docker-distribution.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2018-02-23 15:33:28 EST; 7s ago
 Main PID: 1277 (registry)
   CGroup: /system.slice/docker-distribution.service
           └─1277 /usr/bin/registry serve /etc/docker-distribution/registry/config.yml

Feb 23 15:33:28 rhserver1.example.com systemd[1]: Started v2 Registry server for Docker.
Feb 23 15:33:28 rhserver1.example.com systemd[1]: Starting v2 Registry server for Docker...
Feb 23 15:33:28 rhserver1.example.com registry[1277]: time="2018-02-23T15:33:28-05:00" level=warning msg="No HTTP secret provided - generated random secret. ...
Feb 23 15:33:28 rhserver1.example.com registry[1277]: time="2018-02-23T15:33:28-05:00" level=info msg="redis not configured" go.version=go1.8.3 insta...unknown"
Feb 23 15:33:28 rhserver1.example.com registry[1277]: time="2018-02-23T15:33:28-05:00" level=info msg="Starting upload purge in 1m0s" go.version=go1....unknown"
Feb 23 15:33:28 rhserver1.example.com registry[1277]: time="2018-02-23T15:33:28-05:00" level=info msg="using inmemory blob descriptor cache" go.versi...unknown"
Feb 23 15:33:28 rhserver1.example.com registry[1277]: time="2018-02-23T15:33:28-05:00" level=info msg="listening on [::]:5000" go.version=go1.8.3 ins...unknown"
Hint: Some lines were ellipsized, use -l to show in full.
~~~

See if you can `curl` the registry. Two braces `{}` should be returned.
~~~shell
# curl localhost:5000/v2/
~~~

To check the firewall, `curl` the {{RHSERVER_1}} and {{RHSERVER_2}} registries from {{RHSERVER_0}}.
~~~shell
# curl {{RHSERVER_1}}:5000/v2/
~~~
Expected Output:

~~~shell
{}
~~~~

{% endif %}

#### Exercise: Container Run Time Configuration

##### Goals

* Configure the container run time to use the registries.

##### Howto

Install your favorite text editor if you wish to use something other then **vi**.
~~~
# yum -y install vim nano
~~~

Edit the `/etc/containers/registries.conf` file to include your registries.

~~~shell
[registries.insecure]
registries = ['rhserver1.example.com:5000','rhserver2.example.com:5000']
~~~~

Check that you can restart the container run time service.

~~~shell
# systemctl restart docker
# systemctl status docker
~~~
Expected Output:

~~~shell
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2018-02-23 15:54:06 EST; 3s ago
     Docs: http://docs.docker.com
 Main PID: 2184 (dockerd-current)
   CGroup: /system.slice/docker.service
           ├─2184 /usr/bin/dockerd-current --add-runtime docker-runc=/usr/libexec/docker/docker-runc-current --default-runtime=docker-runc --authorization-pl...
           └─2190 /usr/bin/docker-containerd-current -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --shim docker-containerd-shim --metrics-i...

Feb 23 15:54:05 rhserver0.example.com dockerd-current[2184]: time="2018-02-23T15:54:05.260766730-05:00" level=info msg="libcontainerd: new containerd ...: 2190"
Feb 23 15:54:06 rhserver0.example.com dockerd-current[2184]: time="2018-02-23T15:54:06.326661971-05:00" level=info msg="Graph migration to content-add...econds"
Feb 23 15:54:06 rhserver0.example.com dockerd-current[2184]: time="2018-02-23T15:54:06.327740491-05:00" level=info msg="Loading containers: start."
Feb 23 15:54:06 rhserver0.example.com dockerd-current[2184]: time="2018-02-23T15:54:06.344364014-05:00" level=info msg="Firewalld running: false"
Feb 23 15:54:06 rhserver0.example.com dockerd-current[2184]: time="2018-02-23T15:54:06.550958269-05:00" level=info msg="Default bridge (docker0) is as...ddress"
Feb 23 15:54:06 rhserver0.example.com dockerd-current[2184]: time="2018-02-23T15:54:06.624650802-05:00" level=info msg="Loading containers: done."
Feb 23 15:54:06 rhserver0.example.com dockerd-current[2184]: time="2018-02-23T15:54:06.624750170-05:00" level=info msg="Daemon has completed initialization"
Feb 23 15:54:06 rhserver0.example.com dockerd-current[2184]: time="2018-02-23T15:54:06.624774642-05:00" level=info msg="Docker daemon" commit="3e8e77d...=1.12.6
Feb 23 15:54:06 rhserver0.example.com dockerd-current[2184]: time="2018-02-23T15:54:06.642692378-05:00" level=info msg="API listen on /var/run/docker.sock"
Feb 23 15:54:06 rhserver0.example.com systemd[1]: Started Docker Application Container Engine.
Hint: Some lines were ellipsized, use -l to show in full.
~~~~

#### Exercise: Tagging and pushing images to a remote registry

##### Goals
* Loading an image from an archive. 
* Tag and push an image to a remote registry.

##### Howto

Load the *mystery* image from the content server {{SERVER_DIST}}.
~~~
# wget -O - http://{{SERVER_DIST}}/content/images/mystery.tar | docker load
~~~

Now tag and push the *mystery* image to the remote registry hosted at {{RHSERVER_1}}.
~~~
# docker tag mystery {{RHSERVER_1}}:5000/mystery
# docker push {{RHSERVER_1}}:5000/mytery
~~~