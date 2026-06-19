terraform {
  backend "s3" {
    bucket         = "terraform-s3-statefile-12345"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
#    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
