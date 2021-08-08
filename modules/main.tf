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