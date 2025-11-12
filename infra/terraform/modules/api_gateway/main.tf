resource "aws_api_gateway_rest_api" "rest" {
  name        = "${var.project_name}-api-${var.environment}"
  description = "REST API for ${var.project_name} (${var.environment})"
}

resource "aws_cloudwatch_log_group" "apigw_logs" {
  name              = "/aws/apigateway/${var.project_name}-api-${var.environment}"
  retention_in_days = 14
}

# /request resource
resource "aws_api_gateway_resource" "request" {
  rest_api_id = aws_api_gateway_rest_api.rest.id
  parent_id   = aws_api_gateway_rest_api.rest.root_resource_id
  path_part   = "request"
}

# POST /request method
resource "aws_api_gateway_method" "post_request" {
  rest_api_id   = aws_api_gateway_rest_api.rest.id
  resource_id   = aws_api_gateway_resource.request.id
  http_method   = "POST"
  authorization = "NONE"
}

# Lambda proxy integration
resource "aws_api_gateway_integration" "post_request_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.rest.id
  resource_id             = aws_api_gateway_resource.request.id
  http_method             = aws_api_gateway_method.post_request.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.producer_lambda_arn}/invocations"
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "allow_apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvokePostRequest"
  action        = "lambda:InvokeFunction"
  function_name = var.producer_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest.execution_arn}/*/POST/request"
}

resource "aws_api_gateway_deployment" "current" {
  rest_api_id = aws_api_gateway_rest_api.rest.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.post_request.id,
      aws_api_gateway_integration.post_request_proxy.id
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.post_request_proxy,
    aws_api_gateway_method.post_request
  ]
}


resource "aws_api_gateway_stage" "stage" {
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.rest.id
  deployment_id = aws_api_gateway_deployment.current.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_logs.arn
    format = jsonencode({
      requestId = "$context.requestId",
      status    = "$context.status",
      path      = "$context.path",
      ip        = "$context.identity.sourceIp"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_account.account,
    aws_cloudwatch_log_group.apigw_logs
  ]
}

resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = var.apigw_cloudwatch_role_arn

  depends_on = [var.apigw_cloudwatch_role_arn]
}

