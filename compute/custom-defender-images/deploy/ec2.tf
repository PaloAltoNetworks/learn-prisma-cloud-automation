resource "aws_eip" "eip_mgmt" {
  vpc               = true
  network_interface = aws_network_interface.mgmt_interface.id
  depends_on        = [aws_instance.pc_defender] // to avoid dependency during deletion
}

resource "aws_network_interface" "mgmt_interface" {
  subnet_id         = aws_subnet.private_subnet.id
  security_groups   = ["${aws_security_group.aws-vm-sg.id}"]
  source_dest_check = "false"
}

resource "aws_instance" "pc_defender" {
  depends_on           = [aws_subnet.private_subnet]
  ami                  = data.aws_ami.ubuntu-linux-2004.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.pc_defender_profile_for_ec2.name
  key_name             = aws_key_pair.key_pair.key_name
  user_data            = file("setup.sh") # Optional if using install script
  network_interface {
    network_interface_id = aws_network_interface.mgmt_interface.id
    device_index         = 0
  }
  # root disk
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
    encrypted             = true
  }
  # extra disk - Optional
  #ebs_block_device {
  #  device_name           = "/dev/xvda"
  #  volume_size           = var.data_volume_size
  #  volume_type           = var.data_volume_type
  #  encrypted             = true
  #  delete_on_termination = true
  #}

  tags = {
    Name = var.vm_name
  }
}
