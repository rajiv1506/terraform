variable "egress" {
  type = list(number)
  default = [ -1, 0 ]
}

variable "ingress" {
  type = list(number)
  default = [ 22, 80 ]
}