variable "ingress" {
  type = map(string)
  default = {
      ssh = "22"
      jen = "8080"
  }
}

variable "egress" {
  type = list(string)
  default = [ "-1", "0" ]
}