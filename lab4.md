## Authorization

### Overview

The container run-time software that ships with RHEL has the ability to block remote registries. For example, in a production environment you might want to prevent users from pulling random containers from the public internet by blocking Docker Hub (docker.io). During this lab you will configure the container run-time on {{SERVER_0}} to block the registry on {{SERVER_2}}, then try to pull or run the image from the blocked registry.

#### Exercise

This lab builds on skills you learned in lab 1. On {{SERVER_0}}, perform the following:

* Confirm that {{SERVER_2}} is configured as an insecure registry by tagging and verifying that you can push an image to it.
* Once the push succeeds, remove the local image that was tagged and pushed.
* Next, configure the container run-time to block {{SERVER_2}} and restart the service.
* Now try to pull or run the image that was pushed to the registry on {{SERVER_2}}. It should fail.

#### Hints

Edit the `/etc/containers/registries.conf` file and configure {{SERVER_2}} as a blocked registry.

~~~shell
[registries.block]
registries = ['{{SERVER_2}}:5000']
~~~

~~~shell
# systemctl restart docker
# docker rmi {{SERVER_2}}:5000/mystery:latest

Untagged: rhserver2.example.com:5000/mystery:latest
Untagged: rhserver2.example.com:5000/mystery@sha256:e6f59879436cf2272c1ca14e69e09cb029d13592e38c3d95eee7162d8ef08560

# docker pull {{SERVER_2}}:5000/mystery:latest
~~~

Expected output:

~~~shell
...
Trying to pull repository {{SERVER_2}}:5000/mystery ... 
All endpoints blocked.
~~~
