# creating a vpc in the dev environment
resource "aws_vpc" "main-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "mobikart-vpc"
  }
}

# script to create web server subnet
resource "aws_subnet" "public-sn" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true 
  
  tags = {
    Name = "webserver-mobikart-sn"
  }
}

# script to create backend subnet
resource "aws_subnet" "private-sn1" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  
  tags = {
    Name = "backend-mobikart-sn"
  }
}

# script to create database subnet
resource "aws_subnet" "private-sn2" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  
  tags = {
    Name = "database-mobikart-sn"
  }
}

# script to create IGW
resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "mobikart-igw"
  }
}

# script to create eip for nat gateway
resource "aws_eip" "main-nat-eip" {
  vpc = true
  tags = merge(
      {
          Name = "mobikart-eip"
      } 
  )
}

# script to create nat gateway
resource "aws_nat_gateway" "main-nat" {
  allocation_id = aws_eip.main-nat-eip.id
  subnet_id     = aws_subnet.public-sn.id
  tags = merge(
      {
          Name = "mobikart-nat-gateway"
      }
  )
}

# script to create route table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main-vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }
  tags = {
    Name = "public-mobikart-rt"
  }
}

# script to associate public route table with public subnet
resource "aws_route_table_association" "public-sn-association" {
  subnet_id      = aws_subnet.public-sn.id
  route_table_id = aws_route_table.public-rt.id
}

# PRIVATE ROUTE TABLE RESOURCE & PRIVATE ROUTE TABLE ROUTE RESOURCE
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main-nat.id
  }
  tags = {
    "Name" = "private-mobikart-rt"
  }
}

# PRIVATE ROUTE TABLE ASSOCIATION RESOURCE
resource "aws_route_table_association" "private-mobikart-sn1-association" {
  subnet_id      = aws_subnet.private-sn1.id
  route_table_id = aws_route_table.private-rt.id
}
resource "aws_route_table_association" "private-mobikart-sn2-association" {
  subnet_id      = aws_subnet.private-sn2.id
  route_table_id = aws_route_table.private-rt.id
}
