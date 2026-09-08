terraform {
  backend "s3" {
    bucket       = "travel-terraform-state-bucket"
    key          = "trip/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}