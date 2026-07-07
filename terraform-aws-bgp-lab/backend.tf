terraform {
  backend "s3" {
    bucket  = "terraform-aws-bgp-lab-state-956304646235"
    key     = "terraform-aws-bgp-lab/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
