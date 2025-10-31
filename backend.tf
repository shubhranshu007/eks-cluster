terraform {
  backend "s3" {
    bucket         = "terraform-state-fruitcombo"
    key            = "terraform-s3-statefile-123/terraform.tfstate"
    region         = "us-east-1"
#    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
