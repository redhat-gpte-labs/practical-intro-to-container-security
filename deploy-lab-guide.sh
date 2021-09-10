#!/bin/bash
#
# Script to deploy the lab guide (on Linux) for A Practical Introduction to Container Security.
#

if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "$0 <bastion-public-hostname> <ssh-password>"
    exit 1
fi

student_bastion_hostname=$1
student_ssh_password=$2
student_ssh_command="ssh ${USER}@${student_bastion_hostname}"
port=8080
name='lab-guide'


MY_VARS="{
\"student_bastion_hostname\":\"${student_bastion_hostname}\",
\"student_ssh_command\":\"${student_ssh_command}\",
\"student_ssh_password\":\"${student_ssh_password}\",
\"guid\":\"${GUID}\"
}"

function build() {
	buildah bud -t ${name} .
}

build

running=$(podman ps --filter=name=${name} -q)

if [ ${running} ]; then
	echo "${name} is running, stopping it."
	podman stop ${name}
fi

stopped=$(podman ps -a --filter=name=${name} -q)

if [ ${stopped} ]; then
	echo "${name} has stopped, removing it."
	podman rm ${name}
fi

podman run -d --restart=no --name=${name} -p ${port}:10080 -e WORKSHOP_VARS="${MY_VARS}" localhost/${name}

echo
echo "==================================================================="
echo "Visit the lab guide at http://${student_bastion_hostname}:${port}"
echo "==================================================================="
echo

