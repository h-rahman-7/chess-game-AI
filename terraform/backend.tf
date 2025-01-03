terraform {
  backend "s3" {
    bucket         = "chess-game-terraform-state"
    key            = "terraform/terraform.tfstate" # Prefix for Terraform state
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
