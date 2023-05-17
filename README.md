# Container Security Lab with Red Hat Enterprise Linux 9

## Red Hat Summit 2023.

### Deployment Options

#### 1) To build and host the lab guide on OpenShift refer to [deploy-openshift.md](deploy-openshift.md).

#### 2) To build on the RHPDS bastion (RedHat employees and partners)

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

Run the `deploy-lab-guide.sh` script from the bastion.

#### 3) Red Hat Summit

If you are taking this lab as part of the Red Hat
Summit, a customized bookbag/homeroom environment will be provided for you.
