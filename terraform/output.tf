output "current_iam_creds" {
    value = data.aws_caller_identity.current.arn
}