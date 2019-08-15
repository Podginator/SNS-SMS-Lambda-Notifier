terraform {
  required_version = "= 0.12.6"
}

provider "aws" {
  region              = "${local.aws_region}"
  profile             = "${local.aws_profile}"
}
