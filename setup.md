# Setup notes for summit 2019 

This image started with RHEL8 beta 1v1.7 (internal)

Register 

```
# subscription-manager attach --auto
Installed Product Current Status:
Product Name: Red Hat Enterprise Linux for x86_64 High Touch Beta
Status:       Subscribed

# subscription-manager repos --list-enabled
+----------------------------------------------------------+
    Available Repositories in /etc/yum.repos.d/redhat.repo
+----------------------------------------------------------+
Repo ID:   rhel-8-for-x86_64-appstream-htb-rpms
Repo Name: Red Hat Enterprise Linux 8 for x86_64 - AppStream HTB (RPMs)
Repo URL:  https://cdn.redhat.com/content/htb/rhel8/8/x86_64/appstream/os
Enabled:   1

Repo ID:   rhel-8-for-x86_64-baseos-htb-rpms
Repo Name: Red Hat Enterprise Linux 8 for x86_64 - BaseOS HTB (RPMs)
Repo URL:  https://cdn.redhat.com/content/htb/rhel8/8/x86_64/baseos/os
Enabled:   1

# subscription-manager repos --list|grep "rhel-8"
Repo ID:   cert-1-for-rhel-8-x86_64-debug-rpms
Repo ID:   rhel-8-for-x86_64-baseos-htb-debug-rpms
Repo ID:   fast-datapath-beta-for-rhel-8-x86_64-rpms
Repo ID:   rhel-8-for-x86_64-resilientstorage-htb-rpms
Repo ID:   rhel-8-for-x86_64-baseos-htb-rpms
Repo ID:   rhel-8-for-x86_64-resilientstorage-htb-source-rpms
Repo ID:   rhel-8-for-x86_64-baseos-htb-source-rpms
Repo ID:   fast-datapath-beta-for-rhel-8-x86_64-source-rpms
Repo ID:   rhel-8-for-x86_64-highavailability-htb-rpms
Repo ID:   fast-datapath-beta-for-rhel-8-x86_64-debug-rpms
Repo ID:   rhel-8-for-x86_64-appstream-htb-source-rpms
Repo ID:   rhel-8-for-x86_64-appstream-htb-debug-rpms
Repo ID:   rhel-8-for-x86_64-highavailability-htb-source-rpms
Repo ID:   cert-1-for-rhel-8-x86_64-source-rpms
Repo ID:   rhel-8-for-x86_64-highavailability-htb-debug-rpms
Repo ID:   rhel-8-for-x86_64-appstream-htb-rpms
Repo ID:   rhel-8-for-x86_64-resilientstorage-htb-debug-rpms
Repo ID:   cert-1-for-rhel-8-x86_64-rpms
```

```
# dnf info podman
Updating Subscription Management repositories.
Last metadata expiration check: 0:01:10 ago on Fri 01 Feb 2019 04:33:21 PM CST.
Available Packages
Name         : podman
Version      : 1.0.0
Release      : 1.git82e8011.module+el8+2696+e59f0461
Arch         : x86_64
Size         : 9.0 M
Source       : podman-1.0.0-1.git82e8011.module+el8+2696+e59f0461.src.rpm
Repo         : rhel-8-for-x86_64-appstream-htb-rpms
Summary      : Manage Pods, Containers and Container Images
URL          : https://github.com/containers/libpod
License      : ASL 2.0
Description  : Manage Pods, Containers and Container Images
             : libpod provides a library for applications looking to use
             : the Container Pod concept popularized by Kubernetes.
```

Package installs

``` 
dnf -y install podman skopeo vim
```
Registry installation

```
podman login -u="coreos+rhcp" -p="L6ZXXVHD9XLQ7PR7HBNRW2FAIZQNJYHREISFGCUBIB45C43WCWYU3DZ0FHJH2AY5" quay.io
Login Succeeded!
```

Follow the steps to install Quay in this [kbase article][1] and [installation manual][2].

First setup screen:

```
hostname: container IP
User: root
passwdord: Taken from the (documentation)[2].
```

Use ```podman restart quay``` to restart the quay continer.

2nd setup screen:

```
user: quayuser
passwdord: Taken from the (documentation)[2].
```

Checked: Allow repository pulls even if audit logging fails.

Use IP address of the redis container.

Check:

```
# podman login --tls-verify=false --username=quayuser --password=L36PrivxRB02bqOB9jtZtWiCcMsApOGn quayhost

Username: quayuser
Password: 
Login Succeeded!
podman push --tls-verify=false rhel8kozlab-fedsledsabkozdembr-rcdy9tus.srv.ravcloud.com/quayuser/hello-openshift:latest
```

Questions

1) The atomic command seems to be missing, what takes it's place? Looks like podman covers some. What about scanning (Quay)?

References

[1]: https://access.redhat.com/solutions/3533201
[2]: https://access.redhat.com/documentation/en-us/red_hat_quay/2.9/html-single/deploy_red_hat_quay_-_basic/#installing_red_hat_quay_basic
