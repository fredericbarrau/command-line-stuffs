#!/usr/bin/env bash
#
# This script adds an authentication for a registry to en entire cluster (all namespaces)
#
# Usage: ./add-registry-auth-cluster.sh <registry-domain> <docker-username> <docker-password>
#
# Example: ./add-registry-auth-cluster.sh igxdev.azurecr.io mining-igxdev-pull-only xxxxxxxx
#
#

trap 'echo "# $BASH_COMMAND"' DEBUG

# Exit if any command fails
set -e

# Check for the prerequisites binaries: jq, kubectl
_check=true
for tools in jq kubectl; do
  if ! [ -x "$(command -v $tools)" ]; then
    echo "Error: $tools is not installed." >&2
    _check=false
  fi
done

if [ "$_check" = false ]; then
  echo "Pre-requisites check failed. Please install the missing binaries and try again."
  exit 1
fi

# Check for required parameters
if [ $# -ne 4 ]; then
  echo "Usage: ./add-registry-auth-cluster.sh <registry-domain> <docker-username> <docker-password>"
  exit 1
fi

# Set variables
REGISTRY_DOMAIN=$2
DOCKER_USERNAME=$3
DOCKER_PASSWORD=$4
SECRET_NAME="acr-auth-${REGISTRY_DOMAIN//./-}"
# Looping over the namespaces to create the secret in all Namespaces, except for the namespaces kube-system, kube-public, and kube-node-lease
kubectl get ns --no-headers=true | awk '{print $1}' | grep -v -e kube-system -e kube-public -e kube-node-lease | while read -r namespace; do
  echo "Managing namespace: $namespace"
  # Cleaning up the secrets to be created in the script, if they already exist
  kubectl get secret "$SECRET_NAME" --namespace="$namespace" 2>/dev/null 1>&2 && kubectl delete secret "$SECRET_NAME" --namespace="$namespace"
  # Create the secret
  kubectl create secret docker-registry "$SECRET_NAME" \
    --docker-server="$REGISTRY_DOMAIN" \
    --docker-username="$DOCKER_USERNAME" \
    --docker-password="$DOCKER_PASSWORD" \
    --docker-email="$DOCKER_USERNAME" \
    --namespace="$namespace"
  # Patch the default service account to use the secret, so that all pods in the namespace can use the secret
  # We need to add the secret name to the imagePullSecret list, instead of replacing the list.
  # We also need to remove all duplicates from the list imagePullSecret
  kubectl get serviceaccount default \
    --namespace="$namespace" \
    --output json | jq '.imagePullSecrets |= . + [{"name":"'"$SECRET_NAME"'"}] | .imagePullSecrets |= unique' |
    kubectl replace \
      -f -

done
