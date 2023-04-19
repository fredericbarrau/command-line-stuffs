# GitHub CLI stuffs

## List all the repositories of an organization

```console
$ ORGA=my-orga
$ gh repo list $ORGA -L 100 --json name -q '.[].name'
```

## Add a collaborator to all repo of an organization

```console
$ ORGA=my-orga
$ USERNAME=username
$ gh repo list $ORGA -L 100 --json name -q '.[].name'|xargs -n1 -I{} gh api -XPUT repos/$ORGA/{}/collaborators/$USERNAME -f permission=push --silent
```
