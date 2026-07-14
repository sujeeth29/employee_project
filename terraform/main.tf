module "demo_eks_vpc" {
    source              = "./modules/VPC"
    env                 = var.env
}

module "demo_eks_cluster" {
    source = "./modules/EKS"
    env = var.env
    bastion_instance_type = var.bastion_instance_type
    vpc_id = module.demo_eks_vpc.vpc_id
    demo_eks_public_subnet_1 = module.demo_eks_vpc.demo_eks_public_subnet_1
    demo_eks_public_subnet_2 = module.demo_eks_vpc.demo_eks_public_subnet_2
    demo_eks_private_subnet_1 = module.demo_eks_vpc.demo_eks_private_subnet_1
    demo_eks_private_subnet_2 = module.demo_eks_vpc.demo_eks_private_subnet_2
    demo_eks_private_subnet_1_cidr = module.demo_eks_vpc.demo_eks_private_subnet_1_cidr
    demo_eks_private_subnet_2_cidr = module.demo_eks_vpc.demo_eks_private_subnet_2_cidr
    demo_eks_public_subnet_1_cidr = module.demo_eks_vpc.demo_eks_public_subnet_1_cidr
    demo_eks_public_subnet_2_cidr = module.demo_eks_vpc.demo_eks_public_subnet_2_cidr
    depends_on = [ module.demo_eks_vpc ]
}

module "demo_eks_ecr_repos" {
    source = "./modules/ECR"
    env = var.env
}