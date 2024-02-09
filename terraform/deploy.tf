terraform {
  required_version = "1.6.6"
  backend "s3" {
    region  = "eu-central-1"
    profile = "default"
    key     = "terraformstatefile"
    bucket  = "terraformstatebucketauditsoft6482364"
  }
}
