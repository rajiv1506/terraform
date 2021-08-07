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

# Provosing mediawiki server
resource "aws_instance" "mediawiki" {
  ami = "ami-04bde106886a53080"
  instance_type = var.instancedetails["instance_type"]
  security_groups = [ "${aws_security_group.ssh.name}" ]
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

resource "aws_security_group" "ssh" {
  name = var.security_group_name
}

resource "aws_security_group_rule" "sshtomachine_rule" {
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = var.ingress[0]
  to_port = var.ingress[0]
  security_group_id = aws_security_group.ssh.id
  protocol = "tcp"
  type = "ingress"
}


resource "aws_security_group_rule" "mediwikiport" {
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = 80
  to_port = 80
  security_group_id = aws_security_group.ssh.id
  protocol = "tcp"
  type = "ingress"
}

resource "aws_security_group_rule" "outbound_rule" {
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = var.egress[0]
  to_port = var.egress[1]
  type = "egress"
  protocol = "all"
  security_group_id = aws_security_group.ssh.id
}



