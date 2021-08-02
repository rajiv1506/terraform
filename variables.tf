variable "secrets" {
  type = string
  description = "secret key"
}

variable "access" {
  type = string
  description = "access key"
}

variable "region" {
  type = string
  description = "region"
}

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