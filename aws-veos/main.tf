locals {
    veos_subnet = "${cidrsubnet(var.aws_prefix, 8, 0)}"
    veos_nh     = "${cidrhost(local.veos_subnet, 1)}"
}

data "template_file" "init" {
    template = "${file("init.tpl")}"

    vars {
        # User-defined variables
        username          = "${var.admin_username}"
        password          = "${var.admin_password}"

        # Computed variables
        hostname          = "${var.prefix}-VEOS"
        publicIP          = "${aws_eip.veos.public_ip}"

    }
} 

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "${var.aws_prefix}"
  tags {
      Name = "${var.prefix}-VPC"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags {
      Name = "${var.prefix}-IGW"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a veos subnet
resource "aws_subnet" "veos" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${local.veos_subnet}"
  tags {
      Name = "${var.prefix}-VEOS-SUBNET"
  }
}

# Create a veos NIC
resource "aws_network_interface" "veos" {
  subnet_id = "${aws_subnet.veos.id}"
  source_dest_check = false
  tags {
      Name = "${var.prefix}-NIC"
  }
}


# Default security group
resource "aws_default_security_group" "default" {
  vpc_id      = "${aws_vpc.default.id}"

  # ICMP accessfrom anywhere
  ingress {
    protocol    = "icmp"
    from_port   = "-1"
    to_port     = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # IPsec NAT-T access from anywhere
  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # IPsec IKE access from anywhere
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_key_pair" "auth" {
  key_name   = "${var.prefix}-KEY"
  public_key = "${var.pub_ssh_key}"
}

data "aws_ami" "veos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*EOS*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  #owners = ["083837402522"] # Arista

  owners = ["679593333241"] # Arista (Marketplace)
}

# Create Elastic IP
resource "aws_eip" "veos" {
  vpc      = true
  tags {
      Name = "${var.prefix}-EIP"
  }
}

# Associate Public EIP with ENI
resource "aws_eip_association" "veos" {
  network_interface_id  = "${aws_network_interface.veos.id}"
  allocation_id = "${aws_eip.veos.id}"
}


resource "aws_instance" "veos" {
  
  user_data = "${data.template_file.init.rendered}"

  instance_type = "c4.xlarge"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${data.aws_ami.veos.id}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"


  network_interface {
    network_interface_id = "${aws_network_interface.veos.id}"
    device_index         = 0
  }

  tags {
      Name = "${var.prefix}-VEOS"
  }

  provisioner "remote-exec" {
      inline = [
          "FastCli -p 15 -c \"license import ${var.veos_license}\"",
          "FastCli -p 15 -c \"license import ${var.ipsec_license}\"",
      ]
      connection {
          password = "${var.admin_password}"
          host = "${aws_eip.veos.public_ip}"
      }
      
  }
}




/* 
  From here on we're creating a user subnets and VMs
*/



# Create a user route table
resource "aws_route_table" "user" {
  vpc_id = "${aws_vpc.default.id}"
  tags {
    Name        = "${var.prefix}-RTABLE"
  }
}

# Add a route via VEOS
resource "aws_route" "user_route_veos" {
  route_table_id         = "${aws_route_table.user.id}"
  destination_cidr_block = "${var.azure_prefix}"
  network_interface_id   = "${aws_network_interface.veos.id}"
}

# Add a default route
resource "aws_route" "user_route_internet" {
  route_table_id         = "${aws_route_table.user.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a user subnet
resource "aws_subnet" "user" {
  vpc_id                  = "${aws_vpc.default.id}"
  count                   = "${length(var.user_subnets)}"
  cidr_block              = "${element(var.user_subnets, count.index)}"
  map_public_ip_on_launch = true
  tags {
      Name = "${var.prefix}-USER-SUBNET-$(count.index)"
  }
}

# Assoc subnet with user route table
resource "aws_route_table_association" "user" {
  count          = "${length(var.user_subnets)}"
  subnet_id      = "${element(aws_subnet.user.*.id, count.index)}"
  route_table_id = "${aws_route_table.user.id}"
}

# Pick a linux ami
data "aws_ami" "user" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

# Create a user VM
resource "aws_instance" "user" {
  count         = "${length(var.user_subnets)}"
  ami           = "${data.aws_ami.user.id}"
  instance_type = "t2.micro"

  instance_initiated_shutdown_behavior = "stop"

  subnet_id = "${element(aws_subnet.user.*.id, count.index)}"

  key_name = "${aws_key_pair.auth.id}"

  tags {
    Name        = "${var.prefix}-USER-VM-${count.index}"

  }

}

