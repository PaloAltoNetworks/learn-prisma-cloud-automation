# How to Build a Custom Prisma Cloud Defender Image
A tutorial and set of scripts to help automate Prisma Cloud Defenders by building a Customer AWS AMI.  Additional tutorials & scripts for other CSPs may be added in the future.  Encourage others to contribute as well!

## Prereqs
1. AWS Account
2. Prisma Cloud Enterprise license
3. Terraform
4. AWS CLI

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
- Review additional scripts and setup your secrets in AWS Secrets Manager
- SSH into EC2 instance and create Prisma Cloud Defender install script and systemd service
- Save as new AMI Image with tags
- Deploy new EC2 instance with custom Prisma Cloud Defender AMI
- Verify in Prisma Cloud
