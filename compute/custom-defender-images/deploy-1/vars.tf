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
  type        = list
  description = "list of strings of cidr blocks allowing ssh connections"
  default     = ["0.0.0.0/0"]
}
variable "tls_key_name" {
  type        = string
  description = "key name for tls private key pair"
}
variable "ecr_role_name" {
  type        = string
  description = "Role for permissions to interact with ECR"
  default     = "Custom-AWSECRInstanceUser"
}
variable "ecr_profile_for_ec2" {
  type        = string
  description = "Role for permissions to interact with ECR"
  default     = "ECR-EC2Profile1"
}
variable "ecr_policy" {
  type        = string
  description = "Role for permissions to interact with ECR"
  default     = "ECR-EC2Policy1"
}
