## Configuration
During this lab you will configure {{SERVER_1}} **and** {{SERVER_2}} as container registries then configure the container run-time on {{SERVER_0}} to use them. Most of the remaining lab exercises will be performed on {{SERVER_0}}. These exercises represent the basics of using a container run time.

{% if USE_CRI-O == true %}

#### Modified for CRI-O
Use CRI-O

{% else %}

#### Exercise: Registry Configuration

##### Overview 

* Install, start and enable the registry and firewalld services.
* Open tcp firewall port 5000. 
* Use curl to test connectivity to the registry services.

##### Howto

Perform the following on both {{SERVER_1}} **and** {{SERVER_2}}.

~~~shell
# yum -y install docker-distribution firewalld
# systemctl start docker-distribution firewalld
# systemctl enable docker-distribution firewalld
# firewall-cmd --add-port 5000/tcp --permanent
# firewall-cmd --reload
~~~

Checking the Registry

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

To check the firewall, `curl` the {{SERVER_1}} and {{SERVER_2}} registries from {{SERVER_0}}.

~~~shell
# curl {{SERVER_1}}:5000/v2/
~~~

Expected Output:

~~~shell
{}
~~~~

{% endif %}

#### Exercise: Container Run Time Configuration

##### Overview

* Configure the container run time to use the registries.

##### Howto

Perform the following on {{SERVER_0}}.

Install **wget** and your favorite text editor if you wish to use something other then **vi**.

~~~shell
# yum -y install wget vim nano
~~~

Edit the `/etc/containers/registries.conf` file to include your two registries.

~~~shell
[registries.insecure]
registries = ['{{SERVER_1}}:5000','{{SERVER_2}}:5000']
~~~~

Make sure you can restart the container run time service with no errors before proceeding.

~~~shell
# systemctl restart docker
~~~

#### Exercise: Tagging and pushing images to a remote registry

##### Overview
* Loading an image from an archive. 
* Tag and push an image to a remote registry.

##### Howto

Load the *mystery* image from the content server {{SERVER_DIST}}.

~~~shell
# wget -O - http://{{SERVER_DIST}}/content/images/mystery.tar | docker load
~~~

Verify the image loaded.

~~~shell
# docker images
~~~

Expected Output:

~~~shell
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
mystery                              latest              c82b952c1204        10 months ago       123.4 MB
~~~

Now tag and push the *mystery* image to the remote registry hosted at {{SERVER_1}}.

~~~shell
# docker tag mystery {{SERVER_1}}:5000/mystery
~~~

Confirm the tag is correct.

~~~shell
# docker images
~~~

Expected Output:

~~~shell
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
mystery                              latest              c82b952c1204        10 months ago       123.4 MB
rhserver1.example.com:5000/mystery   latest              c82b952c1204        10 months ago       123.4 MB
~~~

Finally, push the image to the {{SERVER_1}} registry.

~~~shell
# docker push {{SERVER_1}}:5000/mystery
~~~

Expected Output:

~~~shell
The push refers to a repository [rhserver2.example.com:5000/mystery]
86bac94d71f4: Pushed 
5d6cbe0dbcf9: Pushed 
latest: digest: sha256:e6f59879436cf2272c1ca14e69e09cb029d13592e38c3d95eee7162d8ef08560 size: 736
~~~

#### Exercise: Pulling images from a remote registry

##### Overview

* Saving and removing images from the container run-time.
* Pulling an image from a remote registry.

##### Howto

If the push was successful, make a backup copy of the mystery image, delete the local cached images and pull a new image from the remote registry on {{SERVER_1}}. 

~~~shell
# docker save mystery > backup.tar
# docker rmi mystery {{SERVER_1}}:5000/mystery
# docker pull {{SERVER_1}}:5000/mystery
~~~

Expected Output:

~~~shell
Using default tag: latest
Trying to pull repository rhserver1.example.com:5000/mystery ... 
sha256:6b079ae764a6affcb632231349d4a5e1b084bece8c46883c099863ee2aeb5cf8: Pulling from triad.koz.laptop:5000/mystery
Digest: sha256:6b079ae764a6affcb632231349d4a5e1b084bece8c46883c099863ee2aeb5cf8
Status: Downloaded newer image for rhserver1.example.com:5000/mystery
~~~