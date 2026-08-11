output "current_iam_creds" {
    value = data.aws_caller_identity.current.arn
}

output "demo_eks_oidc_url" {
    value = module.demo_eks_cluster.demo_eks_oidc_url
}