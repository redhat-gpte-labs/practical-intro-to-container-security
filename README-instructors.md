# Container Security Lab with Red Hat Enterprise Linux 9

## Instructor's Guide (2021 version)

### Overview

This document provides an overview of the materials and context needed to run a hands-on, technical RHEL container security workshop. This workshop will allow attendees to explore the latest low level features and technology in Red Hat Enterprise Linux 8.4 while learning tangible lessons that can be applied to their job roles. 

The lab was initially created for the 2016 Red Hat Summit and has evolved and been presented each year since then. It
is a low-level, hands-on introduction to container security using the container tools included with Red Hat Enterprise Linux 8.4. It is intended to be consumed as a series of self paced exercises with instructor guidance. Topics include working with user namespaces, secure registries, isolation, SELinux, image inspection, building and the podman API service.

### Prerequisites

Who should attend these workshops?
- Developers of Cloud Native Applications
- Architects with a technical background
- System Administrators

Attendees:
- A basic understanding of working with Linux systems from the command line.
- Must bring a laptop with Chrome 73+, Firefox 60+, Edge 40+, or Safari 12+ installed.
- There is no student prep work required prior to the workshop.
- Fundamental working knowledge Linux containers is helpful but not required.

Instructors and Lab Assistants:
- Basic familiarity with RHEL container tools (podman, skopeo and buildah) and SELinux.
- Trouble shooting container related failures.

### Infrastructure

(3) RHEL 8.4 hosts (Nodes 1 and 2 must be accessed via the bastion)

- Bastion (ports 22 and 8080 are publicly accessible)
- Node 1
- Node 2

### Delivering the Lab

This is largely a self-paced lab session where students work at their own pace and ask questions when
they get stuck. I typically begin by walking everyone through the **Introduction** and **Registry Configuration** labs
together. At this point, students should have (2) working registries and the remainder of the labs can be completed on the
bastion host.

### Troubleshooting and Common Issues

- The best way to help a student is to visit their bookbag URL and see what errors are being reported.
- I often back up to the start of a section in order to follow the path they've taken. 
- Students often type commands into the wrong host.


