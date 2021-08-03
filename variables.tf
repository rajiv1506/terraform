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
    tag_name = "mediawiki"
  }
}

variable "security_group_name" {
  type = string
  default = "ec2access"
}