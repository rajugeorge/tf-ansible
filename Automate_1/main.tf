# define the provider
provider "aws" {
    region = "ap-south-1"
}

#define variables
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location" {}

#define vpc
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

#define subnet
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
      Name: "${var.env_prefix}-subnet-1"
  }
}

#define internet gateway
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
      Name : "${var.env_prefix}-igw"
  }
}

# resource "aws_route_table" "myapp-rtbl" {
#   vpc_id = aws_vpc.myapp-vpc.id
#   route {
#       cidr_block = "0.0.0.0/0"
#       gateway_id = aws_internet_gateway.myapp-igw.id
#   }
#   tags = {
#       Name : "${var.env_prefix}-rtbl"
#   }
# }

# resource "aws_route_table_association" "a-rtb-subnet" {
#   subnet_id = aws_subnet.myapp-subnet-1.id
#   route_table_id = aws_route_table.myapp-rtbl.id
# }

#define default route table
resource "aws_default_route_table" "myapp-rtbl" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
      Name : "${var.env_prefix}-main-rtbl"
  }
}

#define default security group
resource "aws_default_security_group" "default-sg" {
    vpc_id = aws_vpc.myapp-vpc.id 

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
      Name: "${var.env_prefix}-sg"
    }
}

#reference amazon linux
data "aws_ami" "latest-amazon-linux-pakcage" {
    most_recent = true
    owners = ["amazon"]
    filter {
      name = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }
}

#define instance
resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-pakcage.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name
  tags = {
      Name: "${var.env_prefix}-server"
  }
}

#define keypair to ssh
resource "aws_key_pair" "ssh-key" {
  key_name = "aws-test-key"
  public_key = file(var.public_key_location)
}

#debug and see the instance ip
output "instance_name" {
  value = aws_instance.myapp-server.public_ip
}