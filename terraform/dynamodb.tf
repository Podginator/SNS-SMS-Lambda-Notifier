resource "aws_dynamodb_table" "messages" {
  name         = "${local.dynamodb_name}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  hash_key     = "messageId"
  global_secondary_index {
    name               = "PhoneNumberIndex"
    hash_key           = "phoneNumber"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "ALL"
    non_key_attributes = []
  }

  attribute {
    name = "messageId"
    type = "S"
  }

  attribute {
    name = "phoneNumber"
    type = "S"
  }

}

resource "aws_dynamodb_table" "numbers" {
  name         = "${local.dynamodb_name}-phone"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  hash_key     = "phoneNumber"

  attribute {
    name = "phoneNumber"
    type = "S"
  }
}