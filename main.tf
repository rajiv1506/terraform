provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "mediawikistatefile"
    key    = "mediawiki/prod/state.tf"
    region = "ap-south-1"
  }
}

module "vpc" {
  source = "./modules/"
}


data "aws_vpc" "mediawiki_vpc" {
  depends_on = [
    module.vpc
  ]
  filter {
    name = "tag:Name"
    values = ["mediawiki_vpc"]
  }
}

data "aws_subnet" "PublicSubnet" {
  depends_on = [
    module.vpc
  ]
  filter {
    name = "tag:Name"
    values = ["Public Subnet"]
  }
}

data "aws_subnet" "PrivateSubnet" {
  depends_on = [
    module.vpc
  ]
  filter {
    name = "tag:Name"
    values = ["Private Subnet"]
  }
}


# Provosing mediawiki server
resource "aws_instance" "mediawiki" {
  depends_on = [
    module.vpc,aws_security_group.RDP,aws_security_group.ssh
  ]
  ami = "ami-04bde106886a53080"
  subnet_id = data.aws_subnet.PrivateSubnet.id
  instance_type = var.instancedetails["instance_type"]
  vpc_security_group_ids = [ "${aws_security_group.ssh.id}" ]
  key_name = "terraform_winodws"
  user_data = <<-EOF
               #!/bin/bash  
               wget https://apt.puppetlabs.com/puppet5-release-bionic.deb
               sudo dpkg -i puppet5-release-bionic.deb
               sudo apt update -y
               sudo apt install puppet -y
               sudo rm /etc/puppet/puppet.conf /etc/puppetlabs/puppet/puppet.conf -f
               sudo mkdir -p /etc/puppet/
               sudo touch /etc/puppet/puppet.conf 
               echo "[main]" >> /etc/puppet/puppet.conf
               echo "logdir=/var/log/puppet"  |sudo tee -a /etc/puppet/puppet.conf
               echo "vardir=/var/lib/puppet"  | sudo tee -a /etc/puppet/puppet.conf
               echo "ssldir=/var/lib/puppet/ssl" | sudo tee -a /etc/puppet/puppet.conf
               echo "rundir=/var/run/puppet" | sudo tee -a /etc/puppet/puppet.conf
               echo "basemodulepath=./control/modules" | sudo tee -a /etc/puppet/puppet.conf
              EOF
  tags = {
    "Name" = var.instancedetails["tag_name"]
  }
}

resource "aws_instance" "PublicInstance" {
  depends_on = [
    module.vpc,aws_security_group.RDP,aws_security_group.ssh
  ]
  ami = "ami-0655793980c0bf43f"
  subnet_id = data.aws_subnet.PublicSubnet.id
  associate_public_ip_address = true
  instance_type = var.instancedetails["instance_type"]
  key_name = "terraform_winodws"
  vpc_security_group_ids = [ "${aws_security_group.RDP.id}" ]
  tags = {
    "Name" = "PublicInstance"
  }
}

resource "aws_security_group" "RDP" {
  depends_on = [
    module.vpc
  ]
  name = "RDP"
  vpc_id = data.aws_vpc.mediawiki_vpc.id
  egress {
    from_port        = -1
    to_port          =  0
    protocol         = "all"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "ssh" {
  depends_on = [
    module.vpc
  ]
  name = var.security_group_name
  vpc_id = data.aws_vpc.mediawiki_vpc.id

  ingress {
    from_port        = 8
    to_port          = 0
    protocol         = "icmp"
    cidr_blocks      = ["192.168.0.0/24"]
    ipv6_cidr_blocks = ["::/0"]
  
}


resource "aws_security_group_rule" "RDP_rule" {
  depends_on = [
    module.vpc
  ]
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = 3389
  to_port = 3389
  security_group_id = aws_security_group.RDP.id
  protocol = "tcp"
  type = "ingress"
}




resource "aws_security_group_rule" "sshtomachine_rule" {
  depends_on = [
    module.vpc
  ]
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = var.ingress[0]
  to_port = var.ingress[0]
  security_group_id = aws_security_group.ssh.id
  protocol = "tcp"
  type = "ingress"
}


resource "aws_security_group_rule" "mediwikiport" {
  depends_on = [
    module.vpc
  ]
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = 80
  to_port = 80
  security_group_id = aws_security_group.ssh.id
  protocol = "tcp"
  type = "ingress"
}

resource "aws_security_group_rule" "outbound_rule" {
  depends_on = [
    module.vpc
  ]
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = var.egress[0]
  to_port = var.egress[1]
  type = "egress"
  protocol = "all"
  security_group_id = aws_security_group.ssh.id
}










