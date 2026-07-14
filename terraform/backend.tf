terraform {
  backend "s3" {
    bucket = "sujeeth-cloud-storage"
    key = "project-demo-eks/statefiles/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "lock-terraform-state"
    encrypt = true
    }
}