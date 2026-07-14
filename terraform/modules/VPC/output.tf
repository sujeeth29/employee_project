output "vpc_id" {
    value = aws_vpc.demo_eks_vpc.id
}

output "demo_eks_public_subnet_1" {
    value = aws_subnet.demo_eks_public_subnet_1.id
}

output "demo_eks_public_subnet_2" {
    value = aws_subnet.demo_eks_public_subnet_2.id
}

output "demo_eks_private_subnet_1" {
    value = aws_subnet.demo_eks_private_subnet_1.id
}

output "demo_eks_private_subnet_2" {
    value = aws_subnet.demo_eks_private_subnet_2.id
}

output "demo_eks_public_subnet_1_cidr" {
    value = aws_subnet.demo_eks_public_subnet_1.cidr_block
}

output "demo_eks_public_subnet_2_cidr" {
    value = aws_subnet.demo_eks_public_subnet_2.cidr_block
}

output "demo_eks_private_subnet_1_cidr" {
    value = aws_subnet.demo_eks_private_subnet_1.cidr_block
}

output "demo_eks_private_subnet_2_cidr" {
    value = aws_subnet.demo_eks_private_subnet_2.cidr_block
}
