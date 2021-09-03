# A Practical Introduction to Container Security

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

(3) RHEL 8.4 hosts

- Bastion (publicly accessible)
- Node 1
- Node 2

### Common Issues

- Attendee is typing command on the wrong host.
