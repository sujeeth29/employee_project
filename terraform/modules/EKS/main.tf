resource "aws_eks_cluster" "demo_eks_cluster" {
    name = "demo-eks-${var.env}"
    vpc_config {
        endpoint_public_access = true
        endpoint_private_access = true
      subnet_ids = [ 
        var.demo_eks_public_subnet_1,
        var.demo_eks_public_subnet_2
      ]
    }
    version = "1.35"
    access_config {
      authentication_mode = "API"
    }
    role_arn = aws_iam_role.demo_eks_cluster_role.arn
}

resource "aws_security_group_rule" "demo_eks_cluster_ingress_rule" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_group_id = aws_eks_cluster.demo_eks_cluster.vpc_config[0].cluster_security_group_id
    source_security_group_id = aws_security_group.demo_eks_bastion_sg.id
}

resource "aws_iam_role" "demo_eks_cluster_role" {
    name = "demo-eks-${var.env}-cluster-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "sts:AssumeRole",
                    "sts:TagSession"
                ]
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                } 
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "demo_eks_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.demo_eks_cluster_role.name
}

resource "aws_key_pair" "demo_eks_node_group_key" {
    key_name = "demo-eks-${var.env}-NG-key"
    public_key = file("C:/Users/SUJEETH/.ssh/demo_eks_key.pub")
}

resource "aws_security_group" "demo_eks_bastion_sg" {
    name = "demo-eks-${var.env}-bastion"
    vpc_id = var.vpc_id
    description = "Security group for bastion server"
    tags = {
      Name = "demo-eks-${var.env}-bastion"
    }
    ingress  {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 22
        to_port = 22
        protocol = "tcp"
    }
    egress  {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
}

data "aws_ami" "demo_eks_bastion_ami" {
    most_recent = true
    owners = [ "amazon" ]
    filter {
      name = "name"
      values = [ "amzn2-ami-hvm-*-x86_64-gp2" ]
    }

    filter {
      name = "architecture"
      values = [ "x86_64" ]
    }
}

resource "aws_instance" "demo_eks_bastion" {
    ami = data.aws_ami.demo_eks_bastion_ami.id
    instance_type = var.bastion_instance_type
    vpc_security_group_ids = [ aws_security_group.demo_eks_bastion_sg.id ]
    subnet_id = var.demo_eks_public_subnet_1
    key_name = aws_key_pair.demo_eks_node_group_key.key_name
    iam_instance_profile = aws_iam_instance_profile.demo_eks_bastion_instance_profile.name
    tags = {
      Name = "demo-eks-${var.env}-bastion"
    }
  
}

resource "aws_security_group" "demo_eks_node_group_sg" {
    name = "demo-eks-${var.env}-node-group-sg"
    description = "security group for demo eks worker nodes"
    vpc_id = var.vpc_id
    ingress  {
        cidr_blocks = [ 
            var.demo_eks_public_subnet_1_cidr,
            var.demo_eks_public_subnet_2_cidr
        ]
        from_port = 22
        to_port = 22
        protocol = "tcp"
    }
}

resource "aws_eks_node_group" "demo_eks_node_group" {
  cluster_name = aws_eks_cluster.demo_eks_cluster.name
  node_group_name = "demo-eks-${var.env}-node-group"
  node_role_arn = aws_iam_role.demo_eks_node_group_role.arn
  subnet_ids = [ var.demo_eks_private_subnet_1, var.demo_eks_private_subnet_2 ]
  instance_types = [ "t3.medium" ]
  remote_access {
    ec2_ssh_key = aws_key_pair.demo_eks_node_group_key.key_name
    source_security_group_ids = [ aws_security_group.demo_eks_node_group_sg.id ]
  }
  scaling_config {
    desired_size = 1
    max_size = 2
    min_size = 1
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [ 
    aws_eks_cluster.demo_eks_cluster,
    aws_iam_role_policy_attachment.demo_eks_node_group_policy_1,
    aws_iam_role_policy_attachment.demo_eks_node_group_policy_2,
    aws_iam_role_policy_attachment.demo_eks_node_group_policy_3
   ]
}

resource "aws_iam_role" "demo_eks_node_group_role" {
  name = "demo-eks-${var.env}-node-group-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = [
                "sts:AssumeRole"
            ]
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "demo_eks_node_group_policy_1" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.demo_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "demo_eks_node_group_policy_2" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.demo_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "demo_eks_node_group_policy_3" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.demo_eks_node_group_role.name
}

resource "aws_iam_role" "demo_eks_bastion_role" {
    name = "demo-eks-${var.env}-bastion-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "sts:AssumeRole"
                ]
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_policy" "demo_eks_bastion_policy" {
    name = "demo-eks-${var.env}-bastion-policy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "eks:DescribeCluster",
                    "eks:ListClusters"
                ]
                Effect = "Allow"
                Resource = aws_eks_cluster.demo_eks_cluster.arn
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "demo_eks_role_policy_attach" {
    role = aws_iam_role.demo_eks_bastion_role.name
    policy_arn = aws_iam_policy.demo_eks_bastion_policy.arn
}

resource "aws_iam_instance_profile" "demo_eks_bastion_instance_profile" {
    name = "demo-eks-${var.env}-bastion-profile"
    role = aws_iam_role.demo_eks_bastion_role.name
}

resource "aws_eks_access_entry" "demo_eks_bastion_access" {
    cluster_name = aws_eks_cluster.demo_eks_cluster.name
    principal_arn = aws_iam_role.demo_eks_bastion_role.arn
    type = "STANDARD"
}

resource "aws_eks_access_policy_association" "demo_eks_bastion_access_asso" {
    cluster_name = aws_eks_cluster.demo_eks_cluster.name
    principal_arn = aws_iam_role.demo_eks_bastion_role.arn
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    access_scope {
      type = "cluster"
    }
    depends_on = [ aws_eks_access_entry.demo_eks_bastion_access ]
}
