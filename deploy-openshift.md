# Build and Deploy 

## On OpenShift

```
git clone https://github.com/redhat-gpte-labs/practical-intro-to-container-security.git
```
```
cd a-practical-introduction-to-container-security
```
```
oc new-project containersecuritylab
```
```
oc process -f build-template.yaml -p NAME="bookbag" -p GIT_REPO="https://github.com/redhat-gpte-labs/practical-intro-to-container-security.git" | oc apply -f -
```
```
oc start-build bookbag --follow
```
```
oc process -f deploy-template.yaml -p NAME="bookbag" -p IMAGE_STREAM_NAME="bookbag" -p WORKSHOP_VARS="$(cat workshop-vars.json)" | oc apply -f -
```

Grab user.info from agnosticd.
```
grep item=user.info: ~/ansible.log | awk -F"[()]" '{print $2}' | sed -n -e 's/^.*info: //p'
```
To update the WORKSHOP_VARS.

```
oc set env dc/bookbag WORKSHOP_VARS="{\"student_ssh_password\":\"82yTQ08k0XUV\",\"guid\":\"summit\",\"student_bastion_hostname\":\"bastion.summit.sandbox1482.opentlc.com\",\"student_ssh_command\":\"ssh lab-user@bastion.summit.sandbox1482.opentlc.com\"}"
```