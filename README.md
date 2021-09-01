# A Practical Introduction to Container Security - a hands on lab.

## This repo is work in progress for summit 2021.
## [The 2020 lab](https://gitlab.com/2020-summit-labs/a-practical-introduction-to-container-security) is on GitLab.

### Red Hat Summit 2021

#### How to customize and host the lab guide on the bastion.

After the lab is provisioned, you should receive a email with a 
unique *bastion public hostname* and *ssh password*. 

Example email:
```
Here is some important information about your environment:

How to access the lab environment.
The bastion public hostname is <bastion-public-hostname>
The ssh command to use is ssh lab-user@<bastion-public-hostname>
The ssh password is <bastion-ssh-password>
The global user ID (GUID) is XXXX
```

Use your credentials to login to the bastion as `lab-user`.

```
$ ssh lab-user@<bastion-public-hostname>
```

Substitute your `bastion-public-hostname` and `bastion-ssh-password` in the command below to to provision a customized 
lab guide on the bastion.

```
$ bash <(wget -qO- https://raw.githubusercontent.com/bkoz/container-security/2021/deploy-lab-guide.sh) <bastion-public-hostname> <bastion-ssh-password>
```

Example output:
```
Redirecting output to ‘wget-log’.
Trying to pull quay.io/bkozdemb/labguide...
Getting image source signatures
Copying blob a29499e779a7 done
...
...
...
Copying config 49eb97f10c done
Writing manifest to image destination
Storing signatures
e021364f81725e9d897b09c02fec3345b2a7173623938a008be8b08696a069ac

============================================================
Visit the lab guide at http://<bastion-public-hostname>:8080
============================================================
```

push test, delete this line.
