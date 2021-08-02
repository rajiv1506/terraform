provider "aws" {
  region = "ap-south-1"
  access_key = var.access
  secret_key = var.secret
}

terraform {
  backend "local" {
    path = "F:/Backend/terraform.tfstate"
  }
}

variable "test" {
  type = list(string)
  default = [ "mediawiki","jenkins" ]
}

# Provosing mediawiki server

resource "aws_instance" "mediawiki" {
  ami = "ami-04bde106886a53080"
  instance_type = "t2.micro"
  security_groups = [ "${aws_security_group.sshtomachine.name}" ]
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
    "Name" = "mediawiki"
  }
}

/*
resource "aws_instance" "jenkins" {
  ami = "ami-04bde106886a53080"
  instance_type = "t2.micro"
  security_groups = [ "${aws_security_group.jenkins.name}","${aws_security_group.sshtomachine.name}" ]
  key_name = "terraform_winodws"
  connection {
    type = "ssh"
    host = aws_instance.jenkins.public_ip
    user = "ubuntu"
    private_key =  secrets.MYSECRET 
  }
  provisioner "file" {
    source = "script.sh"
    destination = "./script.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x script.sh",
      "sudo ./script.sh"
    ]
  }
  tags = {
    "Name" = "jenkins"
  }
}
*/


resource "aws_security_group" "sshtomachine" {
  name = "sshintoec2"
}

resource "aws_security_group" "jenkins" {
  name = "jenkins"
}

resource "aws_security_group_rule" "sshtomachine_rule" {
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = 22
  to_port = 22
  security_group_id = aws_security_group.sshtomachine.id
  protocol = "tcp"
  type = "ingress"
}

resource "aws_security_group_rule" "mediwikiport" {
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = 80
  to_port = 80
  security_group_id = aws_security_group.sshtomachine.id
  protocol = "tcp"
  type = "ingress"
}

resource "aws_security_group_rule" "jenkins_rule" {
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = 8080
  to_port = 8080
  security_group_id = aws_security_group.jenkins.id
  protocol = "tcp"
  type = "ingress"
}

resource "aws_security_group_rule" "outbound_rule" {
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = var.egress[0]
  to_port = var.egress[1]
  type = "egress"
  protocol = "all"
  security_group_id = aws_security_group.sshtomachine.id
}

