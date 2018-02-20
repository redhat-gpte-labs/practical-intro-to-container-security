## Overview

This lab session is a low-level, hands-on introduction to container security using Red Hat Enterprise Linux 7. It can be delivered by an instructor or consumed as a series of self paced exercises.

Prerequisites

* Fundamental user and administrative Red Hat Enterprise Linux concepts. 
* Basic text editing skills using vim or nano.
* An introductory knowledge of Docker is helpful.

Lab Enviroment

You will be working with the following RHEL7.3 Server systems. 

rhserver0.example.com (Container host)
rhserver1.example.com  (Container registry)
rhserver2.example.com (Container registry)
dist.example.com (Content server)

Login is {{OPENSHIFT_USERNAME}}. Password is {{OPENSHIFT_PASSWORD}}


~~~shell
$ oc login {{OPENSHIFT_MASTER_URL}}
~~~

Enter the username and password provided to you by the instructor:

* Username: {{OPENSHIFT_USERNAME}}
* Password: {{OPENSHIFT_PASSWORD}}

![OpenShift Login]({% image_path ocp-login.png %}){:width="900px"}
