# A Practical Introduction to Container Security

This lab manual is intended to be hosted by the workshopper software. An example is shown below.

At the time of this writing podman needed to be run as root otherwise the container
would not get an IP.
```
sudo podman run --name=workshopper-consec --detach -p 9000:8080 -e WORKSHOPS_URLS="https://raw.githubusercontent.com/bkoz/container-security/2019/_workshop1.yml" osevg/workshopper:latest
```
