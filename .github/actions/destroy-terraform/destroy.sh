#!/bin/bash

set -e

terraform destroy \
  -var-file "$TFVARS_FILE" \
  -auto-approve

terraform workspace select default
terraform workspace delete "$WORKSPACE"

echo "Terraform destroy complete!"