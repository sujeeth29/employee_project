variable "env" {
  type = string
  description = "enter the required environment name"
}

variable "bastion_instance_type" {
  type = string
  description = "enter the required bastion instance type"
  default = "t3.micro"
}
variable "demo_eks_arn" {
  
}


variable "azure_org_id" {
  type = string
  default = "a090bff1-e04c-4e27-8ad5-fbb52af45a97"
  
}