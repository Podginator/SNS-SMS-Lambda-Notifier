locals {
  service_name = "sms_forwarder"

  bucket_name = "sms-forwarder"

  dynamodb_name = "user_messages"

  dynamodb_endpoint = "dynamodb.${local.aws_region}.amazonaws.com"

  aws_region = "eu-west-1"

  aws_profile = "313424333062"

  tags = {
    Name        = "${local.aws_profile}-${local.service_name}"
    Application = "${local.service_name}"
    Service     = "${local.service_name}"
    GitRepo     = "github.com/podginator/${local.service_name}"
    Owner       = "Tom Rogers"
    ManagedBy   = "terraform"
  }
}
