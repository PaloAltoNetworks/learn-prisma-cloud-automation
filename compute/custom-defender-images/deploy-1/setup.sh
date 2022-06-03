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
