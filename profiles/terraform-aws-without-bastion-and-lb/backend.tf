# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "kx-demo1-terraform-state"
    dynamodb_table = "kx-demo1-terraform-state"
    encrypt        = true
    key            = "./terraform.tfstate"
    region         = "us-east-2"
  }
}