## The Atomic Scanner

Before containers are run, it makes good sense to be able to scan container images for known vulnerabilities and configuration problems before they are deployed in the enterprise. RHEL’s atomic scan command can help with this. Additionally, a number of container scanning tools that integrate with Red Hat products are available through third parties such as BlackDuck and TwistLock.

#### OpenSCAP Scanner

Get started by installing the ```atomic``` command and running the built-in atomic scanner that ships with RHEL.

~~~shell
# yum -y install atomic
# atomic scan --help
# atomic scan --list
~~~

Load the OpenScap scanner image. Normally, the ```atomic``` command would pull this image from the [Red Hat Container Catalog](https://access.redhat.com/containers/).

~~~shell
#  wget -O - http://dist.example.com/content/images/openscap.tar | docker load
~~~
Scan the rhel7 image using the default scanner. This will use the default scan type (more about that later). Also scan the mystery image and compare the outputs.

~~~shell
# atomic scan rhel7

docker run -t --rm -v /etc/localtime:/etc/localtime -v /run/atomic/2018-03-28-16-51-16-640723:/scanin -v /var/lib/atomic/openscap/2018-03-28-16-51-16-640723:/scanout:rw,Z -v /etc/oscapd:/etc/oscapd:ro registry.access.redhat.com/rhel7/openscap oscapd-evaluate scan --no-standard-compliance --targets chroots-in-dir:///scanin --output /scanout -j1

rhel7 (d01d4f01d3c4263)

The following issues were found:

     RHSA-2018:0260: systemd security update (Moderate)
     Severity: Moderate
       RHSA URL: https://access.redhat.com/errata/RHSA-2018:0260
       RHSA ID: RHSA-2018:0260-01
       Associated CVEs:
           CVE ID: CVE-2018-1049
           CVE URL: https://access.redhat.com/security/cve/CVE-2018-1049


Files associated with this scan are in /var/lib/atomic/openscap/2018-03-28-16-51-16-640723.

# atomic scan mystery

docker run -t --rm -v /etc/localtime:/etc/localtime -v /run/atomic/2018-03-28-16-52-20-980345:/scanin -v /var/lib/atomic/openscap/2018-03-28-16-52-20-980345:/scanout:rw,Z -v /etc/oscapd:/etc/oscapd:ro registry.access.redhat.com/rhel7/openscap oscapd-evaluate scan --no-standard-compliance --targets chroots-in-dir:///scanin --output /scanout -j1

mystery (c82b952c1204204)

     mystery is not supported for this scan.

Files associated with this scan are in /var/lib/atomic/openscap/2018-03-28-16-52-20-980345.
~~~

Notice the OpenScap scanner has issues with scanning the **mystery** container for [CVEs](https://cve.mitre.org/) so you will deal with this problem in the next lab. 

In addition to container images, running containers can also be scanned. For example, scan the sleepy container that maybe still running from the previous lab.

~~~shell
# docker run -d --name=sleepy rhel7 tail -f /dev/null 
4bfab8d8fefdcf7e312d51bdb9460c1d31bdfb3e69b60863a4cdcc39673b2c38

# docker ps
CONTAINER ID        IMAGE               COMMAND               CREATED             STATUS              PORTS               NAMES
4bfab8d8fefd        rhel7               "tail -f /dev/null"   4 seconds ago       Up 2 seconds                            sleepy
# atomic scan sleepy
...
~~~

Now stop and remove the container.

~~~shell
# docker rm -f sleepy
~~~

How would you scan all running containers on a given host?

~~~shell
# atomic scan --help
~~~

Try running the scanner on an image in one of the remote registries.

~~~shell
# atomic scan {{SERVER_1}}:5000/rhel7
~~~

Look at the contents of the ```/var/lib/atomic/openscap``` directory on the {{SERVER_0}} host and you should see the scanner’s results. The scanner runs as a container and writes the results in the host’s file system using a bind mount. The scanning tools do not run as privileged containers but they are able to mount up a read-only rootfs along with a writeable directory on the host’s file system so the scanner can write the output. You’ll lean more about this feature in the final lab.

~~~shell
# ls -R /var/lib/atomic/openscap/
~~~

#### Scan Types

Scanners can support a number of different scan types. In this section, configure atomic to run the openscap scanner’s ```standards_compliance``` scan type.

Verify the scanner supports the ```standards_compliance``` scan type.

~~~shell
# atomic scan --list
~~~

Now run the scanner using the ```standards_compliance``` scan type.

~~~shell
# atomic scan --scanner openscap --scan_type standards_compliance rhel7
# atomic scan --scanner openscap --scan_type standards_compliance mystery
~~~

