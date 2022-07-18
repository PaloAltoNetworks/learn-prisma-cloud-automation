# Build a Custom Prisma Cloud Defender Image
A tutorial and sample code to help automate and enforce deployments of Prisma Cloud Defenders.

### Why?
- After building a base image, it can be deployed infinite number of times, avoiding having to run deployment scripts after deployment.
- Automated and simplified security is stronger security.
- Defenders PROTECT your applications.  Whereby agentless scanning offers no protection, only visibility of issues.
- Using Prisma Cloud Defender base images significantly eases and strengthens the security of your applications being deployed in cloud-native environments.

### How?
- Create a custom Prisma Cloud Defender base image for your own environment.  
- Enforce the use of the Prisma Cloud defender base image to ensure the defender will launch at every instance bootup with no additional steps required. 
   
#### >>> That's automated security.

### What use case will this tutorial cover?
As of this writing, the tutorial is initially only covering a single use case with building a Custom AWS AMI.  The same logic however can be applied to other Cloud environments and services where Prisma Cloud Defenders may be used.  Highly encourage others to contribute as well!

## Prereqs
1. AWS Account
2. Prisma Cloud Enterprise license
3. Onboarded AWS Account to Prisma Cloud
4. Terraform
5. AWS CLI

## Objectives
1. Build an EC2 Instance with Terraform and initial setup script to install required software for your image
2. SSH into EC2 instance and install new systemd service and scripts for Prisma Cloud Defender to launch on boot
3. OPTIONAL - Setup Secrets to secure credentails (this lab will use AWS Secrets Manager, but you could substitute with other Secrets Managers)
4. Save image as new AMI with custom tags
5. Launch new EC2 instance with your custom Prisma Cloud Defender AMI

### Future Enhancements
- Add [Packer](https://learn.hashicorp.com/collections/packer/aws-get-started) with Provisioner steps to automate image build process
- Add CI tool and steps to automate entire workflow

## Steps

### 01 - Setup
1. Clone this repo
2. Make any necessary adjustments to `default.auto.tfvars` file & deploy to your AWS environment
3. Create a new **Role** in Primsa Cloud called **Defender Manager** and assign it the **Cloud Provisioning Admin** Permission Group
4. Create a new Service Account in Prisma Cloud and assign it your new **Defender Manager** role and create and save keys


### 02 - Review additional scripts and setup your secrets in AWS Secrets Manager
   
1. Open the `pcdefender-install-aws-sm.sh` file in this repo's folder and review the instructions at the top of the script.
2. Create 4 secrets in AWS Secrets Manager.  Note, we utilize using paths for your Secret Names as a good design suggestion to better manage secrets.    
    
| KEY | VALUE | SECRET NAME |
|-----|-------|-------------|
| `PC_USER` | <YOUR_USER_NAME> or <YOUR_ACCESS_KEY> | `pc/defender/pc-user` |
| `PC_PASS` | <YOUR_PASSWORD> or <YOUR_SECRET_KEY> | `pc/defender/pc-pass` |
| `PC_URL` | <PC_URL> | `pc/defender/pc-url` |
| `PC_SAN` | <PC_SAN> | `pc/defender/pc-san` |

3. To create these secrets, follow this helpful guide here, however skip the part about the role as we've already created that from the terraform code:
      - [How to safely use sensitive data at EC2 launch with Secret Manager?](https://filip5114.github.io/ec2-user-data-secret/)
4. Regarding Attaching IAM Role to EC2 Instanct to pull secrets
    - As mentioned, if you used the Terraform code, this step has already been completed for you, however you can also update the terraform code to make this more granular if desired.  
    - For example, you could set the resouce field to something like this: 
        - `"Resource": "arn:aws:secretsmanager:<REGION>:<ACCOUNT_ID>:secret:pc/defender/*"` 
5. To verify your EC2 instance can access your secrets, SSH into your EC2 instance
6. Test that your EC2 instance can acccess your new secrets.  For example:
```
aws secretsmanager get-secret-value --region us-east-1 --secret-id pc/defender/pc-url
```
> Example Output:
```
{
    "ARN": "arn:aws:secretsmanager:us-east-1:533854785587:secret:pc/defender/pc-url-3u2Mb8",
    "Name": "pc/defender/pc-url",
    "VersionId": "d7e9bebb-233e-4ba1-ac67-d407e07163db",
    "SecretString": "{\"PC_URL\":\"https://us-east1.cloud.twistlock.com/us-2-158256885\"}",
    "VersionStages": [
        "AWSCURRENT"
    ],
    "CreatedDate": 1654404957.694
}
```
Or with a command that only filters out the Secret String
```
aws secretsmanager get-secret-value --region us-east-1 --secret-id pc/defender/pc-url --query SecretString --output text
```
> Example Output:
```
{"PC_URL":"https://us-east1.cloud.twistlock.com/us-2-158256885"}
```

Or, just the Value of your secret, using jq to help us filter that out
```
aws secretsmanager get-secret-value --region us-east-1 --secret-id pc/defender/pc-url --query SecretString --output text | jq -r .PC_URL
```
> Example Output:
```
https://us-east1.cloud.twistlock.com/us-2-158256885
```

Filtering out only the value, as shown above is exactly what out script will be doing.


### 03 - Create Prisma Cloud Defender install script and systemd service
1. If not already, SSH into your EC2 instance
2. Change to root user
```
sudo -i
```
3. Create the new script file
```
vi /usr/bin/pcdefender-install-aws-sm.sh
```
- Copy and paste the entire `pcdefender-install-aws-sm.sh` file contents from this repo's folder.
- Save it.
- Make it executable.
```
chmod +x /usr/bin/pcdefender-install-aws-sm.sh 
```

4. Create service file and enable it.
```
vi /lib/systemd/system/pcdefender.service
```
- Copy and paste the entire `pcdefender.service` file contents from this repo's folder.
- Save it.
- Reload the daemon service
```
systemctl daemon-reload 
```
- And enable the service to start on system boot.
```
systemctl enable pcdefender.service 
```
> Example Output:
```
Created symlink /etc/systemd/system/multi-user.target.wants/pcdefender.service → /lib/systemd/system/pcdefender.service.
```

### 04 - Create new Custom AMI Image
1. From your AWS Instances page, right click your instance ID and select **Image and Tempaltes > Create Image**
2. Give it an Image name like `pc-defender-v1.0`
3. Click **Add tag** and provide key/value pair names such as: `image` : `defender`
4. Click **Create Image**

### 05 - Deploy AMI IAM Enforcement Policy for Users
TODO - Add Detail here

### 06 - Deploy new EC2 instance with custom Prisma Cloud Defender AMI
1. Obtain your new **AMI ID** and the values of the **key-pair-name, subnet-id, and sg-id** created from running the initial terraform code.
2. Create the following environment variables, inserting your values between the `""` for each.
```
CUSTOM_AMI_ID=""
KEY_NAME=""
SUBNET_ID=""
SG_ID=""
REGION=""
```

3. Create a new EC2 instance with your custom AMI image.
```
aws ec2 run-instances --image-id $CUSTOM_AMI_ID \
    --instance-type t2.micro \
    --iam-instance-profile Name=PCDefender-EC2Profile1 \
    --key-name $KEY_NAME \
    --subnet-id $SUBNET_ID \
    --security-group-ids $SG_ID \
    --region $REGION \
```

### 07 - Verification
1. After the instance completes initialization, ssh into it with your key-pair and verify the **pcdefender.service** ran successfully.
```
systemctl status pcdefender.service
```
> Example Output:
```
ubuntu@ip-10-0-0-190:~$ systemctl status pcdefender.service 
● pcdefender.service - Prisma Cloud Defender Install Script
     Loaded: loaded (/lib/systemd/system/pcdefender.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Wed 2022-06-08 03:27:28 UTC; 5min ago
    Process: 468 ExecStart=/usr/bin/pcdefender-install-aws-sm.sh (code=exited, status=0/SUCCESS)
   Main PID: 468 (code=exited, status=0/SUCCESS)

Jun 08 03:26:40 ip-10-0-0-190 pcdefender-install-aws-sm.sh[887]:    | | \ \ /\ / / / __| __| |/ _ \ / __| |/ /
Jun 08 03:26:40 ip-10-0-0-190 pcdefender-install-aws-sm.sh[887]:    | |  \ V  V /| \__ \ |_| | (_) | (__|   <
Jun 08 03:26:40 ip-10-0-0-190 pcdefender-install-aws-sm.sh[887]:    |_|   \_/\_/ |_|___/\__|_|\___/ \___|_|\_\
Jun 08 03:27:05 ip-10-0-0-190 pcdefender-install-aws-sm.sh[887]: Performing system checks for defender mode...
Jun 08 03:27:05 ip-10-0-0-190 pcdefender-install-aws-sm.sh[887]: Loading defender images.
Jun 08 03:27:25 ip-10-0-0-190 pcdefender-install-aws-sm.sh[1481]: Loaded image: twistlock/private:defender_22_01_882
Jun 08 03:27:26 ip-10-0-0-190 pcdefender-install-aws-sm.sh[887]: Installing Defender.
Jun 08 03:27:28 ip-10-0-0-190 pcdefender-install-aws-sm.sh[887]: Twistlock Defender installed successfully.
Jun 08 03:27:28 ip-10-0-0-190 pcdefender-install-aws-sm.sh[828]: Installation completed, deleting temporary files.
Jun 08 03:27:28 ip-10-0-0-190 systemd[1]: pcdefender.service: Succeeded.
```

2. Verify you see the new defender in Prisma Cloud by going to **Compute > Manage > Defenders > Manage > Defenders** 
   
3. To verify the ability to launch more than one instance with no other changes, repeat the exact same CLI command and verification steps again.
```
aws ec2 run-instances --image-id $CUSTOM_AMI_ID \
    --instance-type t2.micro \
    --iam-instance-profile Name=PCDefender-EC2Profile1 \
    --key-name $KEY_NAME \
    --subnet-id $SUBNET_ID \
    --security-group-ids $SG_ID \
    --region $REGION \
```
    
## Congratulations
- You created a Custom Image with Prisma Cloud Defender
- You created an image tagging and IAM policy to enforce the use of the image
- As a bonus you also used a Secrets Manager to secure your sensitive credentials 

## Simplified and Automated security that PROTECTS your workloads!  That's the power of Primsa Cloud!

#### Additional References: 
- [Secrets Manager IAM Role Examples](https://docs.aws.amazon.com/mediaconnect/latest/ug/iam-policy-examples-asm-secrets.html)

