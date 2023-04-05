#!/bin/bash
set -xeuo pipefail
ansible-playbook -i deploy/config/gpte-config.yml deploy/playbook.yml
