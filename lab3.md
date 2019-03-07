## Configuration
During this lab you will configure {{SERVER_1}} to host a container registry.

#### Exercise: Registry Configuration

##### Overview 

* Configure the quay registry with the mysql and redis IPs.
* Open firewall ports.
* Use curl to test connectivity to the registry services.

##### Howto

Perform this lab exercise on the ${{SERVER_1}} server.

Start the ```mysql``` and ```redis``` containers.

~~~shell
# podman start mysql redis
~~~

Next, obtain the IP addresses of the ```mysql``` and ```redis```
containers and use them to configure the ```quay``` container.

~~~shell
# podman inspect mysql | grep IPAddress
# podman inspect redis | grep IPAddress
~~~

Use a text editor to modify ```/pv/quay/config/config.yaml``` at
the following lines:

Modify Line 5 with the correct IP of the ```mysql``` container.

Line 5:```DB_URI: mysql+pymysql://root:L36PrivxRB02bqOB9jtZtWiCcMsApOGn@10.88.0.X/enterpriseregistrydb```

Modify Lines 4 and 49 with the correct IP of the ```redis``` container.

Line 4:```BUILDLOGS_REDIS: {host: 10.88.0.X, port: 6379}```

Line 49:```USER_EVENTS_REDIS: {host: 10.88.0.X, port: 6379}```

Now start the quay container and test it. It may take a minute 
or so for the Quay registry to become ready.

~~~shell
# podman start quay
~~~

Checking the Registry

~~~shell
# curl http://localhost:/v2/_catalog
~~~

Expected output:

~~~shell
{"repositories":[]}
~~~

Visit the [quay registry](http://rhel8kozlab-fedsledsabkozdembr-rcdy9tus.srv.ravcloud.com) from a web browser.

Use ```podman``` to login to the Quay registry.

~~~shell
$ podman login --tls-verify=false --username=quayuser --password=L36PrivxRB02bqOB9jtZtWiCcMsApOGn ${{SERVER_1}}
~~~

Expected output:

~~~shell
Login Succeeded!
~~~

#### Exercise: Container Engine Time Configuration

##### Overview

* Configure the container run time to use the registries.

##### Howto

-> Perform the following on {{SERVER_0}}.

Install **wget** and your favorite text editor if you wish to use something other then **vim**.

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

IMPORTANT: Repeat the tag and push to {{SERVER_2}}.

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