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
         
Additional References: 
- [Secrets Manager IAM Role Examples](https://docs.aws.amazon.com/mediaconnect/latest/ug/iam-policy-examples-asm-secrets.html)


### Steps Continued
- SSH into EC2 instance and create Prisma Cloud Defender install script and systemd service
- Save as new AMI Image with tags
- Deploy AMI IAM Enforcement Policy for Users
- Deploy new EC2 instance with custom Prisma Cloud Defender AMI
- Verify in Prisma Cloud
