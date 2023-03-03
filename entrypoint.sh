#!/bin/bash

set -euo pipefail
IFS=$(printf ' \n\t')

debug() {
  if [ "${ACTIONS_RUNNER_DEBUG:-}" = "true" ]; then
    echo "DEBUG: :: $*" >&2
  fi
}

if [ -n "${INPUT_OCI_CLI_USER:-}" ]; then
  export OCI_CLI_USER="${INPUT_OCI_CLI_USER}"
fi

if [ -n "${INPUT_OCI_CLI_TENANCY:-}" ]; then
  export OCI_CLI_TENANCY="${INPUT_OCI_CLI_TENANCY}"
fi

if [ -n "${INPUT_OCI_CLI_KEY_CONTENT:-}" ]; then
  export OCI_CLI_KEY_CONTENT="${INPUT_OCI_CLI_KEY_CONTENT}"
fi

if [ -n "${INPUT_OCI_CLI_REGION:-}" ]; then
  export OCI_CLI_REGION="${INPUT_OCI_CLI_REGION}"
fi

if [ -n "${INPUT_OCI_CLI_FINGERPRINT:-}" ]; then
  export OCI_CLI_FINGERPRINT="${INPUT_OCI_CLI_FINGERPRINT}"
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