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

## Add a webhook for atlantis to all the projects in a org


```console
$ ORGA=my-orga
$ ATLANTIS_URL=https://my-atlantis.com/events
$ ATLANTIS_SECRET=som3-53kRetZ


$ gh auth refresh -h github.com -s admin:repo_hook
````

```bash
#!/usr/bin/env bash
gh repo list $ORGA -L 100 --json name -q '.[].name'|while IFS="" read REPO;do
(cat << EOF
{
  "config": {
    "content_type": "json",
    "insecure_ssl": "0",
    "secret": "$ATLANTIS_SECRET",
    "url": "$ATLANTIS_URL"
  },
  "events": [
    "issue_comment",
    "pull_request",
    "pull_request_review",
    "push"
  ],
  "name": "web"
}
EOF
) | gh api repos/${ORGA}/$REPO/hooks --input - -X POST
done
```