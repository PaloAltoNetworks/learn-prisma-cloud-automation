#Create VPC for entire setup . Keeping the entire setup in controlled env
resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    tags ={
        Name = "${var.vm_name}-vpc"
    }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags ={
        Name = "${var.vm_name}-igw"
    }
}

# Subnet (private)
resource "aws_subnet" "private_subnet" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = false
    tags ={
        Name = "${var.vm_name}-subnet"
    }
}

resource "aws_route_table" "new_route" {
    vpc_id = "${aws_vpc.vpc.id}"

    # Default route through Internet Gateway
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }
    tags ={
        Name = "${var.vm_name}-route"
    }
}
resource "aws_route_table_association" "private_route" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.new_route.id

}
