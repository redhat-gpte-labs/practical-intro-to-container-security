## Introduction

This lab session is a low-level, hands-on introduction to container security using Red Hat Enterprise Linux 8. It can be delivered by an instructor or consumed as a series of self paced exercises.

### Prerequisites

* Fundamental Red Hat Enterprise Linux user and administrator concepts. 
* Basic text editing skills using vim or nano.
* An introductory knowledge of Docker is helpful.

#### Lab Environment

![Lab Diagram]({% image_path con-sec-lab.png %})

You will be working with the following systems running Red Hat Enterprise Linux (RHEL) version 8.0. 

* {{SERVER_0}} (Container Engine)
* {{SERVER_1}} (Container Registry)
* {{SERVER_2}} (Container Registry)
* {{SERVER_DIST}} (Bob to try reposync)
  * Repos
    * rhel-8-server-rpms 
  * Content (container images, scanner example code) 

{{SERVER_0}}, {{SERVER_1}} and {{SERVER_2}} can only be accessed from a bastion host which is publicly accessible via ssh.

##### Lab Environment

##### DIY (External to Red Hat)
You can easily build out this lab yourself. Just get a hold of (3) RHEL8.0 servers that are subscribed to the repos listed above then contact bkozdemb@redhat.com for the image content (I can't host it external to Red Hat). The bastion host is optional.

#### Exercise

Access the {{SERVER_0}}, {{SERVER_1}} and {{SERVER_2}} systems as follows.

1) Using an ssh client, substitute the global user id (**GUID**) and your RHPDS user-name to login to the bastion host.

~~~shell
$ ssh -i .ssh/summit-key.pem lab-user@{{BASTION}}
~~~

