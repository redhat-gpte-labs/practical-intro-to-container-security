## Authorization

### Overview

The Docker software that ships with RHEL has the ability to block remote registries. For example, in a production environment you might want to prevent users from pulling random containers from the public internet by blocking Docker Hub (docker.io). During this lab you will configure docker on {{SERVER_0}} to block the registry on {{SERVER_2}}, then try to pull or run the image from the blocked registry.

#### Howto

