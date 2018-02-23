## Configuration
During this lab you will configure {{SERVER_1}} **and** {{SERVER_2}} as container registries then configure the container run-time on {{SERVER_0}} to use them. Most of the remaining lab exercises will be performed on {{SERVER_0}}. 

{% if USE_CRI-O == true %}

#### Modified for CRI-O
Use CRI-O

{% else %}

#### Exercise: Registry Configuration

##### Goals 

* Install, start and enable the registry service.
* Open tcp firewall port 5000. 
* Use curl to test connectivity to the registry services.

##### Howto

Perform the following on both {{SERVER_1}} **and** {{SERVER_2}}.

~~~shell
# yum -y install docker-distribution
# systemctl start docker-distribution
# systemctl enable docker-distribution
# firewall-cmd --add-port 5000/tcp --permanent
# firewall-cmd --reload
~~~
~~~shell
# systemctl status docker-distribution
~~~~
Expected Output:

~~~shell
Registry status goes here
~~~

~~~shell
# curl localhost:5000/v2/
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

Edit the following variables in the `/etc/sysconfig/docker` file.

~~~shell
ADD_REGISTRY=’--add-registry rhserver1.example.com:5000 --add-registry rhserver2.example.com:5000’

INSECURE_REGISTRY=’--insecure-registry rhserver1.example.com:5000 --insecure-registry rhserver2.example.com:5000’
~~~~

Now restart the container run time service.

~~~shell
# systemctl restart docker
~~~
