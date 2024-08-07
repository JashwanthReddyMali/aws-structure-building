#!/usr/bin/env bash

# Usage: cdk-bootstrap-everywhere.sh [ACCOUNT_ID]

ACCOUNT_ID=$1
shift

[[ -z $ACCOUNT_ID ]] && echo "[ERROR] ACCOUNT_ID is required. Usage: cdk-bootstrap-everywhere.sh [ACCOUNT_ID]" && exit 1

CURRENT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
CDK_BOOTSTRAP_SCRIPT="$CURRENT_PATH/cdk-bootstrap-to.sh"
REGIONS=($(aws ec2 describe-regions --all-regions --filter Name=opt-in-status,Values=opt-in-not-required --query "Regions[].{Name:RegionName}" --output text))
N_REGIONS="${#REGIONS[@]}"

for ((i=0 ; i<$N_REGIONS ; i++)); do
    region=${REGIONS[@]:$i:1}
    echo "[INFO] Bootstrapping $ACCOUNT_ID in region $region ($((i+1))/$N_REGIONS)"
    check_auth=$(aws sts get-caller-identity --region $region 2>&1)
    [[ $? -ne 0 ]] && echo "[WARNING] Skipping region $region: cannot authenticate with this region" && continue
    bash $CDK_BOOTSTRAP_SCRIPT $ACCOUNT_ID $region "$@"
done

echo "[INFO] Deployment completed for $ACCOUNT_ID in the following regions: ${REGIONS[@]}"
