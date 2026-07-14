locals {
  emp_modules = ["${var.env}_emp_frontend", "${var.env}_emp_backend"]
}

resource "aws_ecr_repository" "demo_eks_ecr_repos" {
    for_each = toset(local.emp_modules)
    name = each.value
    image_tag_mutability = "IMMUTABLE"
    image_scanning_configuration {
      scan_on_push = true
    }
    encryption_configuration {
      encryption_type = "AES256"
    }
    tags = {
      Environment = "QA"
    }
}
