variable "env" {
    description = "enter your environment"
    type = string
}

variable "bastion_instance_type" {
    description = "enter the bastion required instance type"
    type = string
    default = "t3.micro"
}

variable "vpc_id" {

}

variable "demo_eks_public_subnet_1" {
  
}

variable "demo_eks_public_subnet_2" {
  
}

variable "demo_eks_private_subnet_1" {
}

variable "demo_eks_private_subnet_2" {
}

variable "demo_eks_public_subnet_1_cidr" {
  
}

variable "demo_eks_public_subnet_2_cidr" {
  
}

variable "demo_eks_private_subnet_1_cidr" {
  
}

variable "demo_eks_private_subnet_2_cidr" {
  
}