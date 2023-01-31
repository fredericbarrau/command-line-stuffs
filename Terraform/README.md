# Terraform stuffs


## Aliases

```shell
terraform_plan() {
  if terraform validate; then
    :
  else
    echo "validate failed"
    return 1
  fi
  ENV=$(terraform workspace show)
  if [[ -z $TF_NO_WS ]] && [[ $ENV == "default" ]]; then
    echo "ERRPR: workspace is default"
    return 1
  fi
  if [[ -z $TF_NO_WS ]]; then
    var_file="--var-file=vars/$(terraform workspace show).tfvars"
  else
    var_file=""
  fi
  # shellcheck disable=SC2086
  terraform plan $var_file -out terraform.plan "$@"
}

alias terp="terraform_plan"
alias terws='terraform workspace select $(terraform workspace list|fzf)'
alias ters='terraform show -json terraform.plan|jq -r '"'"'.resource_changes[]|select(.change.actions[0] != "no-op")|.address'"'"'|fzf -m|xargs printf -- "-target='"'"'%s'"'"' "|xargs -t -J{} terraform plan {} -out=terraform.plan -parallelism=100'
```


## Targetting resources from a plan which modifies a lot of stuffs

```console
$ terraform init
$ terraform plan -out=terraform.plan
$ terraform show -json terraform.plan|\
 jq -r '.resource_changes[]|select(.change.actions[0] != "no-op")|.address'|\
 fzf -m|\
 xargs printf -- "-target='%s' "|\
 xargs -t -J {} terraform plan {} -out=terraform.plan
```

