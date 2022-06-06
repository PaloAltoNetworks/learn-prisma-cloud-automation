#!/bin/bash
# This Bash script can be used to deploy a Container Defender.
# This is a modified version of script here: https://github.com/PaloAltoNetworks/prisma-cloud-compute-sample-code/blob/main/deployment/shell/linux-container-defender.sh

### INSTRUCTIONS ###
# The script requires one variable and 4 secrets to authenticate with Prisma Cloud.
# PC_PATH

# This script additionally utilizes AWS Secrets Manager and jq
# Becasue it utilizes AWS services directly, you must attach a role to the EC2 instance that has proper permissions to fetch the secrets

# To use this script, instead of entering the 4 variables directly here, you will create 4 new secrets in AWS Secrets Manager with a path for each
# If using SaaS, PC_USER and PC_PASS will be an access key and secret key.
# PC_URL should be the exact value copied from Compute > Manage > System > Utilities > Path to Console
# PC_URL="" #https://us-west1.cloud.twistlock.com/us-3-xxxxxxxxx
# PC_SAN="" #us-west1.cloud.twistlock.com

# Each PATH must be set here.  Make sure it matches what you configure in Secrets Manager.
# Recommed using a unique path (like a directory) for your Prisma Cloud secrets such as:

### ONLY MODIFY THESE VALUES IF NEEDED ###
# PC_USER_PATH="pc/defender/PC_USER"
# PC_PASS_PATH="pc/defender/PC_PASS"
# PC_URL_PATH="pc/defender/PC_URL"
# PC_SAN_PATH="pc/defender/PC_SAN"
PC_PATH="pc/defender"

### DO NOT MODIFY BELOW ###

# Automatically retrieve the REGION the EC2 instance is running by accessing metadata server
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
# 'secret-id' paths must match what you configure in your AWS Secrets Manager.
PC_USER="$(aws secretsmanager get-secret-value --region $REGION --secret-id $PC_PATH --query SecretString --output text | jq -r .PC_USER)"
PC_PASS="$(aws secretsmanager get-secret-value --region $REGION --secret-id $PC_PATH --query SecretString --output text | jq -r .PC_PASS)"
PC_URL="$(aws secretsmanager get-secret-value --region $REGION --secret-id $PC_PATH --query SecretString --output text | jq -r .PC_URL)"
PC_SAN="$(aws secretsmanager get-secret-value --region $REGION --secret-id $PC_PATH --query SecretString --output text | jq -r .PC_SAN)"

# Placeholder for proxy, however not yet tested.  See here: https://github.com/PaloAltoNetworks/prisma-cloud-compute-sample-code/blob/main/deployment/shell/linux-container-defender.sh
# May also require modification to the AUTH_DATA & curl command to add --data field - TBD
# Specifiy regional proxy here
#PROXY="http://proxy.address" #http://proxy.address
#NOPROXY="169.254.169.254" # 169.254.169.254 comma separated list, if needed

AUTH_DATA=$(cat <<EOF
{
  "username":"${PC_USER}",
  "password":"${PC_PASS}"
}
EOF
)

# Need to filter just the token out
TOKEN=$(curl -sSLk -d "${AUTH_DATA}" -H 'content-type: application/json' "${PC_URL}/api/v1/authenticate" | jq -r '.token')

# This command is from the Console - Compute > Manage > Defenders > Deploy, last line at the bottom.
curl -sSL -k --header "authorization: Bearer ${TOKEN}" -X POST ${PC_URL}/api/v1/scripts/defender.sh  | bash -s -- -c "${PC_SAN}" -d "none"   
