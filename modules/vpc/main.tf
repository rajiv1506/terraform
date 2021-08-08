terraform {
  required_version = "1.0.2"
}

resource "aws_vpc" "mediawiki_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "mediawiki_vpc"
  }
}

resource "aws_subnet" "PublicSubnet" {
  cidr_block = var.vpc_public_subnet
  availability_zone = "ap-south-1a"
  vpc_id = aws_vpc.mediawiki_vpc.id
  tags = {
    "Name" = "Public Subnet"
  }
}

resource "aws_subnet" "PrivateSubnet" {
  cidr_block = "192.168.0.128/25"
  availability_zone = "ap-south-1a"
  vpc_id = aws_vpc.mediawiki_vpc.id
  tags = {
    "Name" = "Private Subnet"
  }
}

resource "aws_internet_gateway" "internet" {
  vpc_id = aws_vpc.mediawiki_vpc.id
  tags = {
    "Name" = "InternetGateway"
  }
}

resource "aws_route_table" "Public_Route" {
  depends_on = [
    aws_internet_gateway.internet
  ]
  vpc_id = aws_vpc.mediawiki_vpc.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.internet.id
  }
  tags = {
    "Name" = "Public_Route"
  }
}

