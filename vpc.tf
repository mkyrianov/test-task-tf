resource "aws_vpc" "web_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "Web VPC"
  }
}

resource "aws_subnet" "public_ap-southeast-2a" {
  vpc_id     = aws_vpc.web_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "Public Subnet ap-southeast-2a"
  }
}

resource "aws_subnet" "public_ap-southeast-2b" {
  vpc_id     = aws_vpc.web_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "Public Subnet ap-southeast-2b"
  }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    Name = "My VPC - Internet Gateway"
  }
}

resource "aws_route_table" "my_vpc_public" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_vpc_igw.id
  }

  tags = {
    Name = "Public Subnets Route Table for My VPC"
  }
}

resource "aws_route_table_association" "my_vpc_ap-southeast-2a_public" {
  subnet_id = aws_subnet.public_ap-southeast-2a.id
  route_table_id = aws_route_table.my_vpc_public.id
}

resource "aws_route_table_association" "my_vpc_ap-southeast-2b_public" {
  subnet_id      = aws_subnet.public_ap-southeast-2b.id
  route_table_id = aws_route_table.my_vpc_public.id
}