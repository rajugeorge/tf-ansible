#define vpc
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

module "myapp-subnet" {
  source = "./modules/subnet"

  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

module "myapp-webserver" {
  source = "./modules/webserver"

  vpc_id = aws_vpc.myapp-vpc.id
  avail_zone = var.avail_zone
  my_ip = var.my_ip
  env_prefix = var.env_prefix
  image_name = var.image_name
  public_key_location = var.public_key_location
  instance_type = var.instance_type 
  subnet_id = module.myapp-subnet.subnet.id
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