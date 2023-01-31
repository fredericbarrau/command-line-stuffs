# Gcloud stuffs

## Get the roles of a services account

```console
$ GCLOUD_PROJECT=<YOUR GCLOUD PROJECT>
$ SERVICE_ACCOUNT="<YOUR SERVICE ACCOUNT>"
$ gcloud projects get-iam-policy $GCLOUD_PROJECT  \
--flatten="bindings[].members" \
--format='table(bindings.role)' \
--filter="bindings.members:$SERVICE_ACCOUNT"

```