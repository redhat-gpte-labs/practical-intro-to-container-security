## Custom Scanners


The atomic scanner was designed with a pluggable architecture to allow developers to write custom scanners using any programming language supported by RHEL. Adding a scanner plugin involves the following:

* Make atomic aware of your plug-in.
* Ensure the plugin obtains the proper input from the /scanin directory. 
* Ensure the plugin writes the results to the /scanout directory.

#### Installing a custom scanner

Start by grabbing a copy of the custom scanner templates from the content server.

~~~shell
# cd 
# wget -r --no-parent --reject="index.html*" http://dist.example.com/content/custom-scanner/
# cd {{SERVER_DIST}}/content/custom-scanner
~~~

Next, build a docker image that contains the new scanner.

~~~shell
# docker build --rm=true --force-rm=true --tag=example_plugin .

Sending build context to Docker daemon 7.168 kB
Step 1 : FROM rhel7
 ---> d01d4f01d3c4
Step 2 : LABEL INSTALL 'docker run -it --rm --privileged -v /etc/atomic.d/:/host/etc/atomic.d/ $IMAGE sh /install.sh'
 ---> Running in fb2675d26027
 ---> 6f3843112cc8
Removing intermediate container fb2675d26027
Step 3 : ADD example_plugin /
 ---> 018d43a416c7
Removing intermediate container 7ae788ab2af2
Step 4 : ADD list_rpms.py /
 ---> c69ac20c2ab6
Removing intermediate container ab7a3f2abd12
Step 5 : ADD install.sh /
 ---> a0aae7f340e1
Removing intermediate container b09a6f5cfa1f
Successfully built a0aae7f340e1
~~~

The ```example_plugin``` image should appear in the docker image cache.

~~~shell
# docker images
REPOSITORY                                  TAG                 IMAGE ID            CREATED             SIZE
example_plugin                              latest              a0aae7f340e1        36 seconds ago      196.1 MB
~~~

Now install the scanner and confirm it is configured.

~~~shell
# atomic install --name example_plugin example_plugin

docker run -it --rm --privileged -v /etc/atomic.d/:/host/etc/atomic.d/ example_plugin sh /install.sh
Copying example_plugin configuration file to host filesystem...
'/example_plugin' -> '/host/etc/atomic.d/example_plugin'

# atomic scan --list
...
Scanner: example_plugin 
  Image Name: example_plugin
     Scan type: rpm-list * 
     Description: List all RPMS

     Scan type: get-os 
     Description: Get the OS of the object
~~~

The atomic scanner should report the new scanner along with it's 2 scan types. Also, the example_plugin file should appear in the ```/etc/atomic.d``` directory. 

~~~shell
# ls /etc/atomic.d

example_plugin  openscap
~~~

Setting the default scanner.

Edit ```/etc/atomic.conf``` and set the ```example_plugin``` as the default scanner:

~~~shell
default_scanner: example_plugin
~~~

Confirm the default setting.

~~~shell
# atomic scan --list
...

Scanner: example_plugin * 
~~~

Run the new scanner using the default scan type against the **rhel7** image. It should produce a list of rpms that it found. Also run it against the **mystery** image and compare the output.

~~~shell
# atomic scan rhel7
...
rhel7 (d01d4f01d3c4263)

The following results were found:

       rpms:
         tzdata-2017c-1.el7.noarch
         ...
         ...
         ...
         rootfiles-8.1-11.el7.noarch


Files associated with this scan are in /var/lib/atomic/example_plugin/2018-03-28-17-52-22-890090.

# atomic scan mystery

Files associated with this scan are in /var/lib/atomic/example_plugin/2018-03-28-17-54-31-511614.
~~~

It looks like the mystery image does not contain rpms. Now use a specific scan_type with your example_plugin to find out more about the mystery image.

~~~shell
# atomic scan --scanner example_plugin --scan_type=get-os mystery

rhserver1.example.com:5000/mystery (caabc754b7c7dc6)

The following results were found:

       os_release: None
~~~

Still no luck. We’ll modify the scanner source code in the section below to recognize non-RHEL containers.

#### Writing a custom scanner

As an example of how to create a custom scanner, you’ll make changes to the custom scanner source code and rebuild it's container image. 

Have a look at the scanner source code in the ```list_rpms.py``` source file. The atomic scan command will bind mount directories so the scanner container can read from the ```/scanin``` directory and write to the ```/scanout``` directory.

Make a backup copy of the ```list_rpms.py``` file then modify the custom scanner python source code according to the following. 

~~~shell
# cp list_rpms.py list_rpms.py.bak
~~~

Changing the custom scanner.

Feel free to experiment but a simple change would be at **line 39**. Insert an ```‘etc/debian_version’``` element into the array after the ```'etc/redhat-release'``` element.

TIP: Run ```vi``` with the ```"+set number"``` option to turn on line numbering.

~~~shell
# vim "+set number" list_rpms.py
~~~

Your source should look like the following.

~~~shell
35     def get_os(self):
     36         for _dir in self._dirs:
     37             full_indir = os.path.join(self.INDIR, _dir)
     38             os_release = None
     39             for location in ['etc/release', 'etc/redhat-release', 'etc/debian_version']:
     40                 try:
~~~

Now, make a backup copy of the original scanner image by tagging the latest image as v1 then re-build the scanner container.

~~~shell
# docker tag example_plugin:latest example_plugin:v1
# docker build --rm=true --force-rm=true --tag=example_plugin .
# docker images

REPOSITORY                                  TAG                 IMAGE ID            CREATED             SIZE
example_plugin                              latest              e3b4ac53d796        7 seconds ago       196.1 MB
example_plugin                              v1                  a0aae7f340e1        18 minutes ago      196.1 MB
~~~

Now run the modified example_plugin scanner on the mystery image again. If everything worked, the scanner should help you determine the OS version of the mystery image.

~~~shell
# atomic scan --scanner example_plugin --scan_type=get-os mystery
~~~

Output

~~~shell
docker run -t --rm -v /etc/localtime:/etc/localtime -v /run/atomic/2018-04-13-11-53-20-983326:/scanin -v /var/lib/atomic/example_plugin/2018-04-13-11-53-20-983326:/scanout:rw,Z -v /tmp/foobar:/foobar example_plugin python list_rpms.py get-os

mystery (c82b952c1204204)

The following results were found:

       os_release: 8.7



Files associated with this scan are in /var/lib/atomic/example_plugin/2018-04-13-11-53-20-983326.
~~~

#### The End

This concludes the lab on container security. We hope you had fun and learned something in the process. Thanks for attending and please complete the survey so we can improve this course for next year.

Bob, Dan and Mrunal



