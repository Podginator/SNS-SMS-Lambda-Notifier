resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "${local.service_name}-api-gateway"
  description = "x-api-key authentication proxy"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "proxy_api" {
  depends_on = [
    "aws_api_gateway_integration.get_sms_int",
    "aws_api_gateway_integration.post_sms_int",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "rest_api_stage" {
  stage_name    = "dev"
  rest_api_id   = "${aws_api_gateway_rest_api.rest_api.id}"
  deployment_id = "${aws_api_gateway_deployment.proxy_api.id}"

  // @SEE https://github.com/terraform-providers/terraform-provider-aws/issues/162
  description = <<DESCRIPTION

DESCRIPTION

  tags = "${local.tags}"
}

resource "aws_api_gateway_resource" "sms_proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  parent_id = "${aws_api_gateway_rest_api.rest_api.root_resource_id}"
  path_part = "sms"
}

resource "aws_api_gateway_method" "post_sms" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.sms_proxy.id}"
  http_method = "POST"

  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_sms_int" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.sms_proxy.id}"
  http_method = "${aws_api_gateway_method.post_sms.http_method}"
  integration_http_method = "${aws_api_gateway_method.post_sms.http_method}"

  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${local.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.sms_post.arn}/invocations"


  request_parameters = {
  }
}


resource "aws_api_gateway_resource" "phone_proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  parent_id = "${aws_api_gateway_resource.sms_proxy.id}"
  path_part = "{proxy+}"
}

resource "aws_api_gateway_method" "get_sms" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.phone_proxy.id}"
  http_method = "GET"

  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "get_sms_int" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.phone_proxy.id}"
  http_method = "${aws_api_gateway_method.get_sms.http_method}"
  integration_http_method = "POST"

  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${local.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.sms_get.arn}/invocations"
}
