# Create VPC in eu-central-1
resource "aws_vpc" "vpc_master" {
  provider             = aws.region-master
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-apache-server"
  }

}

#Create IGW 
resource "aws_internet_gateway" "igw" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
}

#Get all available AZ`s in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"
}

#create subnet  1 
resource "aws_subnet" "subnet_1" {
  provider          = aws.region-master
  availability_zone = data.aws_availability_zones.azs.names[0]
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"
}

resource "aws_route_table" "internet_route" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Master-Region-RT"
  }
}

resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  provider       = aws.region-master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route.id
}
