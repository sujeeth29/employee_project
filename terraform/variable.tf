variable "env" {
  type = string
  description = "enter the required environment name"
}

variable "bastion_instance_type" {
  type = string
  description = "enter the required bastion instance type"
  default = "t3.micro"
}

