provider "aws" {
  region = "ap-south-1"
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
  connection {
    type = "ssh"
    host = aws_instance.mediawiki.public_ip
    user = "ubuntu"
    private_key = file("F:/terraform_creds/terraform_winodws.pem")
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
    "Name" = "mediawiki"
  }
}

resource "aws_instance" "jenkins" {
  ami = "ami-04bde106886a53080"
  instance_type = "t2.micro"
  security_groups = [ "${aws_security_group.jenkins.name}","${aws_security_group.sshtomachine.name}" ]
  key_name = "terraform_winodws"
  connection {
    type = "ssh"
    host = aws_instance.jenkins.public_ip
    user = "ubuntu"
    private_key = file("F:/terraform_creds/terraform_winodws.pem")
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

