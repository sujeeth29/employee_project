output "demo_eks_frontend_repo_url" {
  value = aws_ecr_repository.demo_eks_ecr_repos["${var.env}_emp_frontend"]
}

output "demo_eks_backend_repo_url" {
  value = aws_ecr_repository.demo_eks_ecr_repos["${var.env}_emp_backend"]
}