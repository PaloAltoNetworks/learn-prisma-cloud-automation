# Define the security group for the Linux server
resource "aws_security_group" "aws-vm-sg" {
  name        = "${var.vm_name}-sg"
  description = "Allow incoming traffic to the EC2 Instance"
  vpc_id      = aws_vpc.vpc.id   #Optional if creating new VPC.  If commented out, will use default.
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTPS/TLS connections"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Define the Allowable SSH address(es)
    cidr_blocks = var.ssh_cidr_blocks
    description = "Allow incoming SSH connections"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
