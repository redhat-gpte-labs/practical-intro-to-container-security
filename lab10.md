## Custom Scanners


The atomic scanner was designed with a pluggable architecture to allow developers to write custom scanners using any programming language supported by RHEL. Adding a scanner plugin involves the following:

* Make atomic aware of your plug-in.
* Ensure the plugin obtains the proper input from the /scanin directory. 
* Ensure the plugin writes the results to the /scanout directory.

#### Installing a custom scanner

~~~shell
# cd /root/custom-scanner
~~~

Build a docker image that contains the new scanner.

~~~shell
# docker build --rm=true --force-rm=true --tag=example_plugin .
~~~

The example_plugin image should appear in the docker image cache.

~~~shell
# docker images

REPOSITORY       TAG                 IMAGE ID            CREATED             SIZE
example_plugin   latest              4a7521646d99        6 seconds ago       1.434 GB
~~~

Now install the scanner and confirm it is configured.

~~~shell
# atomic install --name example_plugin example_plugin
# atomic scan --list
~~~

It should report 2 scanners each with 2 scan types. Also, the example_plugin file should appear in the ```/etc/atomic.d``` directory. 

~~~shell
# ls /etc/atomic.d

example_plugin  openscap
~~~

Edit ```/etc/atomic.conf``` and set the following:

~~~shell
default_scanner: example_plugin
~~~

Confirm the default setting.

~~~shell
# atomic scan --list

Scanner: example_plugin * 
~~~

Run the new scanner using the default scan type against the rhel7 image. It should produce a list of rpms that it found. Also run it against the mystery image and compare the output.

~~~shell
# atomic scan rhel7
# atomic scan mystery
~~~

Use a specific scanner and scan_type to find out more about the mystery image that you pushed to the registry on rhserver1.

~~~shell
# atomic scan --scanner example_plugin --scan_type=get-os mystery

rhserver1.example.com:5000/mystery (caabc754b7c7dc6)

The following results were found:

       os_release: None
~~~

We’ll modify the scanner source code in the next lab to recognize non-rhel containers and file systems.

#### Writing a custom scanner

As an example of how to create a custom scanner, you’ll make changes to the custom scanner source code and rebuild it's container image. 

~~~shell
# cd /root/custom-scanner
~~~

Have a look at the scanner source code in the list_rpms.py source file. The atomic scan command will bind mount directories so the scanner container can read from the /scanin directory and write to the /scanout directory.

Change to the custom_scanner directory and begin by making a backup copy of the list_rpms.py file then modify the custom scanner python source code according to the following. 

Feel free to do your own thing but a simple, change would be at line 39. Insert an ‘etc/debian_version’ element into the array after the 'etc/redhat-release' element. Now, make a backup copy of the original scanner image by tagging the latest image as v1 then re-build the scanner container.

~~~shell
# docker tag example_plugin:latest example_plugin:v1
# docker images
# docker build --rm=true --force-rm=true --tag=example_plugin .
~~~

Now run the modified example_plugin scanner on the mystery image again. If everything worked, the scanner should help you solve the mystery.

~~~shell
# atomic scan --scanner example_plugin --scan_type=get-os mystery
~~~

#### The End

This concludes the lab on container security. We hope you had fun and learned something in the process. Thanks for attending and please complete the survey so we can improve this course for next year.

Bob, Dan and Mrunal



