## Introduction

This lab session is a low-level, hands-on introduction to container security using Red Hat Enterprise Linux 7. It can be delivered by an instructor or consumed as a series of self paced exercises.

### Prerequisites

* Fundamental Red Hat Enterprise Linux user and administrator concepts. 
* Basic text editing skills using vim or nano.
* An introductory knowledge of Docker is helpful.

#### Lab Enviroment

You will be working with the following RHEL7.4 Server systems. 

* {{SERVER_0}} (Container Host)
* {{SERVER_1}}  (Container Registry)
* {{SERVER_2}} (Container Registry)
* {{SERVER_DIST}} (Bastion host and content server)

Each student will be assigned a global user id (GUID) that can be used to ```ssh`` into the bastion host.  

#### Exercise 

Login to the bastion host, substitute your GUID below. 

```
ssh cloud-user@GUID.labs.summit.redhat.com
```

#### Exercise

Once you are logged into the bastion host, you can reach the remaining servers using ```ssh``` as the {{ROOT_USERNAME}} user name.

Login for all servers: User: {{ROOT_USERNAME}} Password: {{ROOT_PASSWORD}}

To prepare for the lab, use an ssh client and login to {{SERVER_0}}, {{SERVER_1}} and {{SERVER_2}}.

```
$ ssh {{ROOT_USERNAME}}@{{SERVER_0}}
```

