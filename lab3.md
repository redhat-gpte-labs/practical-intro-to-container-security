In this lab we are going to deploy an application.


{% if JAVA_APP == true %}

#### Deploy a Java Application
Run the following to deploy a Java application

~~~shell
oc new-app https://github.com/sample/parksmap-java.git
~~~

{% else %}

#### Deploy a Python Application
Run the following to deploy a Python application:

~~~shell
oc new-app https://github.com/sample/parksmap-python.git
~~~

{% endif %}
