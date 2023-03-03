# OKE-kubectl

Access your OKE cluster via `kubectl` in a Github Action. 


## Example configuration


```yaml
jobs:
  jobName:
    name: Update deploy
    runs-on: ubuntu-latest 
    steps:
      # --- #
      - name: Build and push CONTAINER_NAME
        uses: jarvan1/eks-kubectl-action@latest
        with:
          oci_cli_user: ${{ secrets.OCI_CLI_USER }}
          oci_cli_tenancy: ${{ secrets.OCI_CLI_TENANCY }}
          oci_cli_fingerprint: ${{ secrets.OCI_CLI_FINGERPRINT }}
          oci_cli_key_content: ${{ secrets.OCI_CLI_KEY_CONTENT }}
          oci_cli_region: ${{ secrets.OCI_CLI_REGION }}
          oke_cluster_id: ${{ secrets.OKE_CLUSTER_ID }}
          args: set image --record deployment/pod-name pod-name=${{ steps.build.outputs.IMAGE_URL }}
      # --- #
```

### Outputs

The action exports the following outputs:
- `kubectl-out`: The output of `kubectl`.

```yaml
jobs:
  jobName:
    name: Update deploy
    runs-on: ubuntu-latest 
    steps:
      # --- #
      - name: Build and push CONTAINER_NAME
        uses: jarvan1/eks-kubectl-action@latest
        with:
          oci_cli_user: ${{ secrets.OCI_CLI_USER }}
          oci_cli_tenancy: ${{ secrets.OCI_CLI_TENANCY }}
          oci_cli_fingerprint: ${{ secrets.OCI_CLI_FINGERPRINT }}
          oci_cli_key_content: ${{ secrets.OCI_CLI_KEY_CONTENT }}
          oci_cli_region: ${{ secrets.OCI_CLI_REGION }}
          oke_cluster_id: ${{ secrets.OKE_CLUSTER_ID }}
          args: set image --record deployment/pod-name pod-name=${{ steps.build.outputs.IMAGE_URL }}
      # --- #
      - name: Use the output
        run: echo "{{ steps.kubectl.outputs.kubectl-out }}"
```