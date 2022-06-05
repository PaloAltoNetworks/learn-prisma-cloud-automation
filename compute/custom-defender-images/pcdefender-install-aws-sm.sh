#!/bin/bash
# This Bash script can be used to deploy a Container Defender.
# This is a modified version of script here: https://github.com/PaloAltoNetworks/prisma-cloud-compute-sample-code/blob/main/deployment/shell/linux-container-defender.sh

### INSTRUCTIONS ###
# This script utilizes jq and AWS Secrets Manager
# To avoid having to set sensitive values statically in this script, it is written to pull 4 secrets you can create in AWS Secrets Manager.
# NOTE: Becasue it requires to fetch the secrets from AWS Secretes Manager,
# you must also attach an IAM role to the EC2 instance that has proper permissions to fetch the secrets.  
# If utilizing the GitHub tutorial this script was created in, the role is created for you via the terraform code.
# Otherwise you will need to create your own IAM role and policy to attach to the EC2 instance.

### GATHER THE 4 VALUES OF YOUR SECRETS ###
# 1) USERNAME and 2) PASSWORD if using Prisma Cloud Self Hosted Compute, OR 1) ACCESS_KEY and 2) SECRET_KEY if using the Enterprise SaaS version.
# 3) PC_URL from Compute > Manage > System > Utilities > Path to Console (i.e: #https://us-west1.cloud.twistlock.com/us-3-xxxxxxxxx)
# 4) PC_SAN (i.e. us-west1.cloud.twistlock.com)

### CREATE THESE SECRETS AS KEY/VALUE PAIRS IN AWS SECRETS MANAGER.
# NOTE: You can change the secret path & names to something else in AWS Secrets Manager, however, you must ensure the VALUES further below match
## KEY ## |  ## VALUE ##                  | ## SECRET PATH/NAME ## |
# PC_USER | <YOUR_USERNAME_OR_ACCESS_KEY> | pc/defender/pc-user    |
# PC_PASS | <YOUR_PASSWORD_OR_SECRET_KEY> | pc/defender/pc-pass    |
# PC_URL  | <YOUR_PC_URL>                 | pc/defender/pc-url     |
# PC_SAN  | <YOUR_PC_SAN>.                | pc/defender/pc-san     |

### ENVIRONMENT VARIABLES USED BY THE SCRIPT ###
### DO NOT MODIFY WHAT IS IN THE "" BELOW UNLESS YOU USED DIFFERENT SECRET PATH/NAMES IN AWS SECRETS MANAGER THAN WHAT WAS SUGGESTED ABOVE ###
PC_USER_PATH="pc/defender/pc-user"
PC_PASS_PATH="pc/defender/pc-pass"
PC_URL_PATH="pc/defender/pc-url"
PC_SAN_PATH="pc/defender/pc-san"


### DO NOT MODIFY BELOW ###

# Automatically retrieve the REGION the EC2 instance is running by accessing metadata server
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

# 'secret-id' paths must match what you configure in your AWS Secrets Manager.
PC_USER="$(aws secretsmanager get-secret-value --region $REGION --secret-id $PC_USER_PATH --query SecretString --output text | jq -r .PC_USER)"
PC_PASS="$(aws secretsmanager get-secret-value --region $REGION --secret-id $PC_PASS_PATH --query SecretString --output text | jq -r .PC_PASS)"
PC_URL="$(aws secretsmanager get-secret-value --region $REGION --secret-id $PC_URL_PATH --query SecretString --output text | jq -r .PC_URL)"
PC_SAN="$(aws secretsmanager get-secret-value --region $REGION --secret-id $PC_SAN_PATH --query SecretString --output text | jq -r .PC_SAN)"

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
