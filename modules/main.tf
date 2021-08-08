terraform {
  required_version = "1.0.2"
}

resource "aws_vpc" "mediawiki_vpc" {
  cidr_block = "192.168.0.0/24"
  tags = {
    "Name" = "mediawiki_vpc"
  }
}

resource "aws_subnet" "PublicSubnet" {
  cidr_block = "192.168.0.0/28"
  vpc_id = aws_vpc.mediawiki_vpc.id
  tags = {
    "Name" = "Public Subnet"
  }
}

resource "aws_subnet" "PrivateSubnet" {
  cidr_block = "192.168.0.128/25"
  vpc_id = aws_vpc.mediawiki_vpc.id
  tags = {
    "Name" = "Public Subnet"
  }
}

resource "aws_internet_gateway" "internet" {
  vpc_id = aws_vpc.mediawiki_vpc.id
  tags = {
    "Name" = "InternetGateway"
  }
}

resource "aws_route_table" "PublicSubnet_Table" {
  vpc_id = aws_vpc.mediawiki_vpc.id

  route = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.internet.id
    },
    {
      ipv6_cidr_block        = "::/0"
      egress_only_gateway_id = aws_internet_gateway.internet.id
    }
  ]

  tags = {
    Name = "PublicSubnet_Table"
  }
}