# AWS Settings
region          = "us-east-1"

# Linux Virtual Machine
vm_name                     = "spring-app"
instance_type               = "t2.micro"
ami_type                    = "ubuntu-linux-2004"
associate_public_ip_address = true
root_volume_size            = 20
root_volume_type            = "gp2"
ssh_cidr_blocks             = ["0.0.0.0/0"]
tls_key_name                = "vm-key-pair"
