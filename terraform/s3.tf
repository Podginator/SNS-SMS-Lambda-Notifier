resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${local.aws_profile}-${local.bucket_name}-lambda"
  acl    = "private"

  tags = "${local.tags}"
}

#Given more time and an appropriate CI/CD Pipeline I would ensure this would not be the way
# We handled Lambda Uploads
resource "aws_s3_bucket_object" "lambda_object" {
  bucket  = "${aws_s3_bucket.lambda_bucket.id}"
  key     = "handler.zip"
  source = "../handler.zip"
}
