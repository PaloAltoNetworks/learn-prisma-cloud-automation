# Terraform files to deploy intial EC2 instance for building custom image

## Instructions
Edit the `default.auto.tfvars` file and enter in your values.

## Sensitive Info & Files
As part of this template, it automatically creates a key pair saved as `.pem` file type.
- The file will be automatically created when you run terraform apply.
- To ensure you don't upload this back to Github, we've added `*.pem` in the **.gitignore** file.
