provider "aws" {
  region = "eu-west-1"
}

# use a remote state
data "terraform_remote_state" "remote-state" {
  backend = "remote"
  config = {
    organization = "pedram-company"

    workspaces = {
      name = "mongodbtest"
    }
  }
}

module "lambda" {
  source  = "app.terraform.io/pedram-company/lambda/aws"
  version = "0.0.6"

  src_path = "${var.lambda_src_path}"
  target_path = "${var.lambda_target_path}"
}

resource "aws_api_gateway_rest_api" "restapi" {
  name = "sentinemnt-api"
  tags = {
    "owner" = "pedram@hashicorp.com"
    "env"   = "dev"
  }
}

//new resource for restapi
resource "aws_api_gateway_resource" "apiresource" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  parent_id   = aws_api_gateway_rest_api.restapi.root_resource_id
  path_part   = "resource"
}
//new method for the resource
resource "aws_api_gateway_method" "getapi" {
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  resource_id   = aws_api_gateway_resource.apiresource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "putapi" {
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  resource_id   = aws_api_gateway_resource.apiresource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.restapi.id
  resource_id             = aws_api_gateway_resource.apiresource.id
  http_method             = aws_api_gateway_method.getapi.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.lambda_invoke_arn
}

resource "aws_api_gateway_integration" "put_integration" {
  rest_api_id             = aws_api_gateway_rest_api.restapi.id
  resource_id             = aws_api_gateway_resource.apiresource.id
  http_method             = aws_api_gateway_method.putapi.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.lambda_invoke_arn
}

resource "aws_lambda_permission" "api_gw" {
  statement_id = "AllowExecutionFromAPIGateway"
  action       = "lambda:InvokeFunction"

  function_name = module.lambda.lambda_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.restapi.execution_arn}/*/*"
}


resource "aws_api_gateway_deployment" "apideployment" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  
}

resource "aws_api_gateway_stage" "restapistage" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  stage_name  = "production"
  deployment_id = aws_api_gateway_deployment.apideployment.id
  description = "this is the prod stage"
  tags = {
    "owner" = "pedram@hashicorp.com"
    "env"   = "dev"
  }
}

