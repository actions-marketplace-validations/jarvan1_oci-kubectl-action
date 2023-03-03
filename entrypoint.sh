#!/bin/bash

set -euo pipefail
IFS=$(printf ' \n\t')

debug() {
  if [ "${ACTIONS_RUNNER_DEBUG:-}" = "true" ]; then
    echo "DEBUG: :: $*" >&2
  fi
}
mkdir -p $HOME/.oci
if [ -n "${INPUT_OCI_CLI_USER:-}" ]; then
  echo "[DEFAULT]" >> $HOME/.oci/config
  echo user=$INPUT_OCI_CLI_USER >> $HOME/.oci/config
fi

if [ -n "${INPUT_OCI_CLI_TENANCY:-}" ]; then
  echo tenancy="${INPUT_OCI_CLI_TENANCY}" >> $HOME/.oci/config
fi

if [ -n "${INPUT_OCI_CLI_KEY_CONTENT:-}" ]; then
  echo "${INPUT_OCI_CLI_KEY_CONTENT}" >> $HOME/.oci/oci_api_key.pem
  echo key_file=$HOME/.oci/oci_api_key.pem >> $HOME/.oci/config
fi

if [ -n "${INPUT_OCI_CLI_REGION:-}" ]; then
  echo region="${INPUT_OCI_CLI_REGION}" >> $HOME/.oci/config
fi

if [ -n "${INPUT_OCI_CLI_FINGERPRINT:-}" ]; then
  echo fingerprint="${INPUT_OCI_CLI_FINGERPRINT}" >> $HOME/.oci/config
fi

if [ -n "${INPUT_OKE_CLUSTER_ID:-}" ]; then
  export OKE_CLUSTER_ID="${INPUT_OKE_CLUSTER_ID}"
fi

if [ -n "${INPUT_MANIFESTS_FILE:-}" ] && [ -n "${INPUT_IMAGE:-}" ]; then
  sed -i "s#image:.*#image: ${INPUT_IMAGE}#g" ${INPUT_MANIFESTS_FILE}
fi

echo "Generate kubeconfig for OKE"
mkdir -p $HOME/.kube

oci ce cluster create-kubeconfig \
--cluster-id ${OKE_CLUSTER_ID} \
--file $HOME/.kube/config \
--region OCI_CLI_REGION \
--token-version 2.0.0  \
--kube-endpoint PUBLIC_ENDPOINT

export KUBECONFIG=$HOME/.kube/config
cat ${INPUT_MANIFESTS_FILE}
debug "Starting kubectl collecting output"
output=$( kubectl "$@" )
debug "${output}"
echo ::set-output name=kubectl-out::"${output}"