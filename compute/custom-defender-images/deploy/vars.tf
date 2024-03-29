variable "region" {
  description = "compute region"
}
variable "vm_name" {
  type        = string
  description = "Referance name for the VM"
}
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}
variable "ami_type" {
  type        = string
  description = "EC2 ami image type"
  default     = "ubuntu-linux-2004"
}
variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address to the EC2 instance"
  default     = true
}
variable "root_volume_size" {
  type        = number
  description = "Volume size of root volume"
}
#variable "data_volume_size" {
#  type        = number
#  description = "Volume size of data volume"
#}
variable "root_volume_type" {
  type        = string
  description = "Volume type of root volume"
  default     = "gp2"
}
#variable "data_volume_type" {
#  type        = string
#  description = "Volume type of data volume"
#  default     = "gp2"
#}
variable "ssh_cidr_blocks" {
  type        = list(any)
  description = "list of strings of cidr blocks allowing ssh connections"
  default     = ["0.0.0.0/0"]
}
variable "tls_key_name" {
  type        = string
  description = "key name for tls private key pair"
}
variable "pc_defender_role_name" {
  type        = string
  description = "Role for permissions to interact with ECR & AWS Secret Manager"
  default     = "Custom-AWSPCDefenderInstanceUser"
}
variable "pc_defender_profile_for_ec2" {
  type        = string
  description = "Role for permissions to interact with ECR & AWS Secret Manager"
  default     = "PCDefender-EC2Profile1"
}
variable "pc_defender_policy" {
  type        = string
  description = "Role for permissions to interact with ECR & AWS Secret Manager"
  default     = "PCDefender-EC2Policy1"
}
variable "ami_tag_key" {
  type        = string
  description = "Custom AMI tag key"
}
variable "ami_tag_value" {
  type        = string
  description = "Custom AMI tag value"
}