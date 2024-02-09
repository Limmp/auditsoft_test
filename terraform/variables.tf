variable "profile" {
  type    = string
  default = "default"

}

variable "region-master" {
  type    = string
  default = "eu-central-1"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}


variable "instance-type" {
  type    = string
  default = "t2.micro"
}

variable "worker-count" {
  type    = number
  default = 3
}


variable "webserver-port" {
  type    = number
  default = 80
}
