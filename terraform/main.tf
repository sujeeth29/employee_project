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

data "aws_eks_cluster_auth" "demo_eks" {
    name = module.demo_eks_cluster.demo_eks_cluster_name
}

provider "kubernetes" {
    host = module.demo_eks_cluster.demo_eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.demo_eks_cluster.demo_eks_cluster_ca_certs)
    token = data.aws_eks_cluster_auth.demo_eks.token
}

provider "helm" {
    kubernetes {
      host = module.demo_eks_cluster.demo_eks_cluster_endpoint
      cluster_ca_certificate = base64decode(module.demo_eks_cluster.demo_eks_cluster_ca_certs)
      token = data.aws_eks_cluster_auth.demo_eks.token
    }
}

resource "kubernetes_service_account_v1" "demo_eks_alb_controller" {
    metadata {
      name = "aws-load-balancer-controller"
      namespace = "kube-system"
      labels = {
        "app.kubernetes.io/name" = "aws-load-balancer-controller"
        "app.kubernetes.io/component" = "controller"
      }
      annotations = {
        "eks.amazonaws.com/role-arn" = module.demo_eks_cluster.demo_eks_alb_controller_role_arn
      }
    }
    depends_on = [ aws_eks_access_policy_association.terraform_admin ]
}

data "aws_region" "current" {}

resource "helm_release" "demo_eks" {
    name = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    chart = "aws-load-balancer-controller"
    namespace = "kube-system"
    version = "1.8.1"

    set { 
        name = "clusterName"
        value = module.demo_eks_cluster.demo_eks_cluster_name 
    }
    set { 
        name = "serviceAccount.create"
        value = "false" 
    }
    set { 
        name = "serviceAccount.name"
        value = kubernetes_service_account_v1.demo_eks_alb_controller.metadata[0].name 
    }
    set { 
        name = "vpcId"
        value = module.demo_eks_vpc.vpc_id 
    }
    set { 
        name = "region"
        value = data.aws_region.current.region 
    }

    # set = [ {
    #         name = "clusterName"
    #         value = module.demo_eks_cluster.demo_eks_cluster_name
    #     },
    #     {
    #         name = "serviceAccount.create"
    #         value = "false"
    #     },
    #     {
    #         name = "vpcId"
    #         value = module.demo_eks_vpc.vpc_id
    #     },
    #     {
    #         name = "region"
    #         value = data.aws_region.current.name
    #     },
    #     {
    #         name = "serviceAccount.name"
    #         value = kubernetes_service_account_v1.demo_eks_alb_controller.metadata[0].name
    #     }, 
    # ]
    depends_on = [ 
        kubernetes_service_account_v1.demo_eks_alb_controller
    ]
    
}

data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "terraform_admin" {
    cluster_name = module.demo_eks_cluster.demo_eks_cluster_name
    principal_arn = data.aws_caller_identity.current.arn
    type = "STANDARD"
}

resource "aws_eks_access_policy_association" "terraform_admin" {
    cluster_name = module.demo_eks_cluster.demo_eks_cluster_name
    principal_arn = data.aws_caller_identity.current.arn
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    access_scope {
      type = "cluster"
    }
    depends_on = [ aws_eks_access_entry.terraform_admin ]
}

resource "aws_iam_openid_connect_provider" "demo_eks_azure_connection" {
    url = "https://vstoken.dev.azure.com/${var.azure_org_id}"
    client_id_list = [ 
        "api://AzureADTokenExchange"
     ]
}

resource "aws_iam_role" "demo_eks_azure_devops" {
    name = "AzureDevopsEksDeploy"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Federated = aws_iam_openid_connect_provider.demo_eks_azure_connection.arn
            }
            Action = [
                "sts:AssumeRoleWithWebIdentity"
            ]
            Condition = {
                StringEquals = {
                    "vstoken.dev.azure.com/${var.azure_org_id}:aud"= "api://AzureADTokenExchange"
                
                    "vstoken.dev.azure.com/${var.azure_org_id}:sub"= "sc://Demo-org203/Demo-org-project-B/aws-service-connection"
                }
            }
        }]
    })
}

resource "aws_iam_role_policy" "demo_eks_azure_devops" {
    name = "AzureDevopsEksPolicy"
    role = aws_iam_role.demo_eks_azure_devops.id
    policy = jsonencode({
        Version = "2012-10-17"

        Statement = [{
            Effect = "Allow"
            Action = [
                "eks:DescribeCluster"
            ]
            Resource = module.demo_eks_cluster.demo_eks_cluster_arn
        }]
    })
}

resource "aws_eks_access_entry" "demo_eks_azure_devops" {
    cluster_name = module.demo_eks_cluster.demo_eks_cluster_name
    principal_arn = aws_iam_role.demo_eks_azure_devops.arn
    type = "STANDARD"
}

resource "aws_eks_access_policy_association" "demo_eks_azure_devops" {
    cluster_name = module.demo_eks_cluster.demo_eks_cluster_name
    principal_arn = aws_iam_role.demo_eks_azure_devops.arn
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    access_scope {
      type = "cluster"
    }
}