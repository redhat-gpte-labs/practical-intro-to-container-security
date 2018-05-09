## Introduction

This lab session is a low-level, hands-on introduction to container security using Red Hat Enterprise Linux 7. It can be delivered by an instructor or consumed as a series of self paced exercises.

### Prerequisites

* Fundamental Red Hat Enterprise Linux user and administrator concepts. 
* Basic text editing skills using vim or nano.
* An introductory knowledge of Docker is helpful.

#### Lab Enviroment

![Lab Diagram]({% image_path con-sec-lab.png %})

You will be working with the following systems running Red Hat Enterprise Linux (RHEL) version 7.5. 

* {{SERVER_0}} (Container Host)
* {{SERVER_1}} (Container Registry)
* {{SERVER_2}} (Container Registry)
* {{SERVER_DIST}} (Bastion host and content server)
  * rhel-7-server-rpms 
  * rhel-7-server-optional-rpms 
  * rhel-7-server-extras-rpms 
  * rhel-7-server-supplementary-rpms 


These servers can only be accessed from a bastion host which is publicly accessible via ssh.

#### Exercise

To get started, make sure you can connect to the bastion host and
the container servers listed above.

Right click on the desktop to open a terminal window.

Substitute the global user id (GUID) you obtained from the registration page to login to the bastion host as the cloud-user login name.

~~~shell
ssh {{BASTION}}
~~~

Once you are logged into the bastion host, you can reach the remaining servers using the {{ROOT_USERNAME}} user name. A suggestion would be to establish (2) ssh sessions to {{SERVER_0}} and an (1) ssh session to {{SERVER_1}} and {{SERVER_2}}.

Credentials for servers: User: {{ROOT_USERNAME}} Password: {{ROOT_PASSWORD}}

~~~shell
$ ssh {{ROOT_USERNAME}}@{{SERVER_0}}
~~~

