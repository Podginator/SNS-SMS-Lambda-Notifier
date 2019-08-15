resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "dynamodb" {
  name = "${local.service_name}-dynamodb-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:Query",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:Scan"
      ],
      "Resource": [
        "${aws_dynamodb_table.numbers.arn}",
        "${aws_dynamodb_table.messages.arn}",
        "${aws_dynamodb_table.messages.arn}/index/PhoneNumberIndex"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "log_groups" {
  name = "${local.service_name}-log-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "sns_policy" {
  name = "${local.service_name}-sns-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:*",
        "SNS:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sns_policy_attachment" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.sns_policy.arn}"
  depends_on = ["aws_iam_role.iam_for_lambda"]
}

resource "aws_iam_role_policy_attachment" "dynamodb_policy_attachment" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.dynamodb.arn}"
  depends_on = ["aws_iam_role.iam_for_lambda"]
}
