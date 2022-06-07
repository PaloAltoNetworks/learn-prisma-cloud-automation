#! /bin/bash

# This script installs Docker on Ubuntu using the repository method
# Instructions found here: https://docs.docker.com/engine/install/ubuntu/

# First uninstall old versions of Docker if there are any
sudo apt-get remove docker docker-engine docker.io containerd runc

# Set up the repository
sudo apt-get update

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install AWS CLI
# Method via apt
sudo apt install -y awscli

# Alternative Method requires unzip and to use curl 
# Install AWS CLI - Ref: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
#sudo apt install unzip
#curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#unzip awscliv2.zip
#sudo ./aws/install

# (OPTIONAL) Install Amazon ECR Docker Credential Helper
sudo apt update
sudo apt install -y amazon-ecr-credential-helper

# Setup Docker credentials
sudo groupadd docker
#sudo usermod -a -G docker $USER
# If above does work, revert back to manually enter user
sudo usermod -a -G docker ubuntu
sudo chmod u+x /usr/bin/docker

# Install jq & verify
sudo apt install -y jq

##############################################
### END OF AUTOMATED SCRIPT ####
##############################################
#***********************************************************************************

##############################################
### MANUAL STEPS AFTER SSH INTO MACHINE ####

# As of now, the below all needs to be done manually after ssh into the machine.

# It is recommended to wait about 3-5 mins after Terraform finishes the apply to allow the instance to boot up and docker service to start.
# Verify can run docker
docker ps

# If you cannot run docker, logoff and log back in.
# If still not working, attempt to troubleshoot and possibly re-paste some of the commands in the script in case they did not apply properly.


## Configure Docker credential helper to interact with ECR
# Additional Ref: https://github.com/awslabs/amazon-ecr-credential-helper#configuration
mkdir ~/.docker/
cat > ~/.docker/config.json << EOF
{
    "credsStore": "ecr-login"
}
EOF

# Verify can pull images from ECR with docker

#docker pull <repo-image-URI>


## To use AWS CLI with ECR, also add the below.
# Configure Amazon ECR credential helper in AWS credentials
mkdir ~/.aws/

## Configure AWS Credentials
# OPTION #1 - Use a credentials file tied to the assumed role - More Secure method
### USE OF THIS OPTION CURRENTLY DOES NOT WORK - DO RESEARCH
#cat > ~/.aws/credentials << EOF
#[default]
#region = us-east-1
#role_arn = <arn>
#credential_source = Ec2InstanceMetadata
#EOF

# Alternatively set with access and secret key
# OPTION #2 - Use `aws configure` to automatically create the credential file

# OPTION #3 - Create credentials file
#[default]
#region = <region>
#aws_access_key_id = <ACCESS-KEY>
#aws_secret_access_key = <SECRET-KEY>


# Verify you can interact with our ECR repo via AWS CLI with this command
#aws ecr list-images --repository-name <repo-name>

#----------------------------------------------------------------------------------- Installation of defender -----------------------------------------------------------------------------------
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
