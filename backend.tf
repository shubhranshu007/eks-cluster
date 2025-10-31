terraform {
  backend "s3" {
    bucket         = "terraform-state-fruitcombo"
    key            = "bucket-terraform-demo-statefile/terraform.tfstate"
    region         = "ap-south-1"
#    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
