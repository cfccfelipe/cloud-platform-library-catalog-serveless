resource "aws_iam_role" "apigw_cloudwatch" {
  name                  = "apigateway-cloudwatch-role-${var.environment}"
  force_detach_policies = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "apigateway.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apigw_cloudwatch_attach" {
  role       = aws_iam_role.apigw_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
