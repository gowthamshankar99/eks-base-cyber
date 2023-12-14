#!/usr/bin/env bash
set -eo pipefail

cluster_name=$1

instance_name=$(jq -er .instance_name "$cluster_name".auto.tfvars.json)
aws_account_id=$(jq -er .aws_account_id "$cluster_name".auto.tfvars.json)
aws_region_current=$(jq -er .aws_region "$cluster_name".auto.tfvars.json)
aws_assume_role=$(jq -er .aws_assume_role "$cluster_name".auto.tfvars.json)

echo $instance_name
echo $aws_account_id
echo $aws_region_current
echo $aws_assume_role


aws sts get-caller-identity

cat <<EOF > .teller.yml
project: poc-platform-eks-base

carry_env: true

opts:
  region: us-east-1

providers:
  aws_secretsmanager:
    env:
      TFE_TEAM_TOKEN:
        path: poc/terraform-cloud
        field: tfe-team-token
      
      CLUSTER_URL:
        path: poc/kubernetes/${instance_name}
        field: cluster-url

      CLUSTER_PUBLIC_CERTIFICATE_AUTHORITY_DATA:
        path: poc/kubernetes/${instance_name}
        field: cluster-public-certificate-authority-data

      KUBECONFIG_BASE64:
        path: poc/kubernetes/${instance_name}
        field: kubeconfig-base64

EOF

# Assume the role and capture the temporary credentials
CREDS=$(aws sts assume-role --role-arn arn:aws:iam::"${aws_account_id}":role/"${aws_assume_role}" --role-session-name "$instance_name")

# Extract and export the temporary credentials
export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r .Credentials.SessionToken)

aws eks update-kubeconfig --name "$instance_name" \
--region "$aws_region_current" \
--role-arn arn:aws:iam::"${aws_account_id}":role/"${aws_assume_role}" --alias "$instance_name" \
--kubeconfig "kubeconfig_$instance_name"

# write kubeconfig to AWS secrets manager
teller put KUBECONFIG_BASE64="$(cat kubeconfig_$instance_name | base64)" --providers aws_secretsmanager -c .teller.yml

# # write cluster url and pubic certificate to AWS secrets manager
teller put CLUSTER_URL="$(terraform output -raw cluster_url)" --providers aws_secretsmanager -c .teller.yml
teller put CLUSTER_PUBLIC_CERTIFICATE_AUTHORITY_DATA="$(terraform output -raw cluster_public_certificate_authority_data)" --providers aws_secretsmanager -c .teller.yml
