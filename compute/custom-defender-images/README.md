# How to Build a Custom Prisma Cloud Defender Image
A tutorial and set of scripts to help automate Prisma Cloud Defenders by building a Customer AWS AMI.  Additional tutorials & scripts for other CSPs may be added in the future.  Encourage others to contribute as well!

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
- Add Packer with Provisioner steps to automate image build process
- Add CI tool and steps to automate entire workflow

## Steps

### 
- Clone repo
- Make any necessary adjustments to `default.auto.tfvars` file & deploy to your AWS environment
- Create a new **Role** in Primsa Cloud called **Defender Manager** and assign it the **Cloud Provisioning Admin** Permission Group
- Create a new Service Account in Prisma Cloud and assign it your new **Defender Manager** role and create and save keys


### Review additional scripts and setup your secrets in AWS Secrets Manager
   
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


### Create Prisma Cloud Defender install script and systemd service
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

### Create new Custom AMI Image
1. From your AWS Instances page, right click your instance ID and select **Image and Tempaltes > Create Image**
2. Give it an Image name like `pc-defender-v1.0`
3. Click **Add tag** and provide key/value pair names such as: `image` : `defender`
4. Click **Create Image**

### Steps Continued

- Deploy AMI IAM Enforcement Policy for Users
- Deploy new EC2 instance with custom Prisma Cloud Defender AMI
- Verify in Prisma Cloud



### Additional References: 
- [Secrets Manager IAM Role Examples](https://docs.aws.amazon.com/mediaconnect/latest/ug/iam-policy-examples-asm-secrets.html)

