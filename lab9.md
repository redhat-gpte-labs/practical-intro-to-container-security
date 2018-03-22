## The Atomic Scanner

Before containers are run, it makes good sense to be able to scan container images for known vulnerabilities and configuration problems before they are deployed in the enterprise. RHEL’s atomic scan command can help with this. Additionally, a number of container scanning tools that integrate with Red Hat products are available through third parties such as BlackDuck and TwistLock.

#### OpenSCAP Scanner

Get started by running the built-in atomic scanner that ships with RHEL.

~~~shell
# atomic scan --help
# atomic scan --list
~~~

Scan the rhel7 image using the default scanner. This will use the default scan type (more about that later). Also scan the mystery image and compare the outputs.

~~~shell
# atomic scan rhel7
# atomic scan mystery
~~~

In addition to container images, running containers can also be scanned. For example, scan the sleepy container that maybe still running from the previous lab.

How would you scan all running containers on a given host?

Try running the scanner on an image in one of the remote registries.

~~~shell
# atomic scan {{SERVER_1}}:5000/rhel7
~~~

Look at the contents of the /var/lib/atomic/openscap directory on the {{SERVER_)}} host and you should see the scanner’s results. The scanner runs as a container and writes the results in the host’s file system using a bind mount. The scanning tools do not run as privileged containers but they are able to mount up a read-only rootfs along with a writeable directory on the host’s file system so the scanner can write the output. You’ll lean more about this feature in the final lab.

~~~shell
# ls -R /var/lib/atomic/openscap/
~~~

#### Scan Types

Scanners can support a number of different scan types. In the section, configure atomic to run the openscap scanner’s standards compliance scan type.

Verify the scanner supports the standards-compliance scan type.

~~~shell
# atomic scan --list
~~~

Now run the scanner using the standards compliance scan type.

~~~shell
# atomic scan --scanner openscap --scan_type standards_compliance rhel7
# atomic scan --scanner openscap --scan_type standards_compliance mystery
~~~

