# Gcloud stuffs


## Get the service accounts (emails) of a projects 

```console
$ gcloud iam service-accounts list --format="table(email)"|tail -n +2
```

## Get the roles of a services account

```console
$ GCLOUD_PROJECT=<YOUR GCLOUD PROJECT>
$ SERVICE_ACCOUNT="<YOUR SERVICE ACCOUNT>"
$ gcloud projects get-iam-policy $GCLOUD_PROJECT  \
--flatten="bindings[].members" \
--format='table(bindings.role)' \
--filter="bindings.members:$SERVICE_ACCOUNT"
```

## Get the service account and their roles of all projects

```
while read project;do
gcloud iam service-accounts list --format="table(email)"|tail -n +2|xargs -n1 -I{} gcloud projects get-iam-policy $project --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:{}"
done < <(gcloud projects list --format="table(PROJECT_ID)"|tail -n +2)
```