# Adding generic webhooks to automate your workflow
## Tested on OpenShift v4.3

Begin by adding a generic webhook to the build config.
```
$ oc set triggers bc bookbag --from-webhook=true
```
Get the webhook URL.

1) Using the web console.

Navigate to:

Builds -> Build Config Details -> Scroll to the bottom of the page to Webhooks -> *Copy URL with secret*

2) Using the CLI.
```
$ oc describe bc bookbag | grep generic

URL: https://api.cluster-rhsummit-dev.rhsummit-dev.events.opentlc.com:6443/apis/build.openshift.io/v1/namespaces/user-bkozdemb-redhat-com/buildconfigs/bookbag/webhooks/<secret>/generic
```

Get the generic webhook secret.
```
$ oc get bc bookbag -o yaml | grep secret

secret: 5xuo7f7GxMIE7nnZVabc
```

Testing the trigger.

Replace your `<secret>` in the URL and use `curl` to trigger an OpenShift build.
 ```
 $ curl -k -X POST https://api.cluster-rhsummit-dev.rhsummit-dev.events.opentlc.com:6443/apis/build.openshift.io/v1/namespaces/user-bkozdemb-redhat-com/buildconfigs/bookbag/webhooks/<secret>/generic
 ```

The final step is to create a webhook trigger in github or gitlab using this URL. Remember to disable SSL verification. Now whenever code is pushed to this repo an OpenShift build will be triggered.