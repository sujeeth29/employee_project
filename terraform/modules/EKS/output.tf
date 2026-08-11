output "demo_eks_bastion_public_ip" {
    value = aws_instance.demo_eks_bastion.public_ip
}
output "demo_eks_cluster_arn" {
    value = aws_eks_cluster.demo_eks_cluster.arn
}

output "demo_eks_cluster_name" {
    value = aws_eks_cluster.demo_eks_cluster.name
}

output "demo_eks_cluster_endpoint" {
    value = aws_eks_cluster.demo_eks_cluster.endpoint
}

output "demo_eks_cluster_ca_certs" {
    value = aws_eks_cluster.demo_eks_cluster.certificate_authority[0].data
}

output "demo_eks_alb_controller_role_arn" {
    value = aws_iam_role.demo_eks_alb_controller_role.arn
}

output "demo_eks_oidc_url" {
    value = aws_eks_cluster.demo_eks_cluster.identity[0].oidc[0].issuer
}