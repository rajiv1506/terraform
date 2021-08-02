variable "SECRET_KEY" {
  type = string
  description = "secret key"
}

variable "ACCESS_KEY" {
  type = string
  description = "access key"
}

variable "REGION" {
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