resource "aws_lambda_function" "sms_post" {
  function_name = "${local.service_name}-post"
  description   = "Post an SMS message to the numbers in the db"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "index.addMessage"
  memory_size   = "1024"
  runtime       = "nodejs8.10"
  timeout       = "30"
  tags          = "${local.tags}"
  s3_bucket     = "${aws_s3_bucket.lambda_bucket.id}"
  s3_key        = "handler.zip"

  environment {
    variables = {
      NODE_ENV             = "production"
      LOG_LEVEL            = "INFO"
      MESSAGE_DB           = "${aws_dynamodb_table.messages.id}"
      PHONE_DB             = "${aws_dynamodb_table.numbers.id}"
      SNS_TOPIC            = "${aws_sns_topic.sms_notifier.id}"
      DDB_ENDPOINT         = "${local.dynamodb_endpoint}"
    }
  }
}

resource "aws_lambda_function" "sms_get" {
  function_name = "${local.service_name}-get"
  description   = "Get Messages from DynamoDB Storage"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "index.getMessages"
  memory_size   = "1024"
  runtime       = "nodejs8.10"
  timeout       = "30"
  tags          = "${local.tags}"
  s3_bucket     = "${aws_s3_bucket.lambda_bucket.id}"
  s3_key        = "handler.zip"

  environment {
    variables = {
      NODE_ENV             = "production"
      LOG_LEVEL            = "INFO"
      MESSAGE_DB           = "${aws_dynamodb_table.messages.id}"
      DDB_ENDPOINT         = "${local.dynamodb_endpoint}"
    }
  }
}

resource "aws_lambda_permission" "get_apigw" {
  statement_id  = "AllowGetAPIGatewayInvoke-${local.service_name}"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sms_get.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn =  "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "post_apigw" {
  statement_id  = "AllowPostAPIGatewayInvoke-${local.service_name}"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sms_post.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn =  "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
}