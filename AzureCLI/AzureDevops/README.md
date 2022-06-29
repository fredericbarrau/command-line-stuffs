# Azure Devops 

## Setup devops extension


> From https://docs.microsoft.com/en-us/azure/devops/cli/?view=azure-devops

```console
az extension add --name azure-devops
```

## List all the repos of all projects

```console
az devops project list|jq -r '.value[].name'|xargs -n1 -I {} az repos list --project {}|jq -r '.[]|[.project.name,.name,.remoteUrl]|@csv'> projects
.csv
```