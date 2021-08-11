variable "egress" {
  type = list(number)
  default = [ -1, 0 ]
}

variable "ingress" {
  type = list(number)
  default = [ 22, 80 ]
}

variable "instancedetails" {
  type = map
  default = {
    instance_type = "t2.micro"
    tag_name = "mediawiki_Demo"
  }
}

variable "security_group_name" {
  type = string
  default = "ec2_mediawiki_Demo"
}

variable "PRIVATE_KEY" {}

variable "cidr_block" {
  type = list(string)
  default = [ "0.0.0.0/0" ]
}

