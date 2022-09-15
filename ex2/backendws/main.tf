provider "aws" {
  region = "eu-west-1"
}

# s3
provider "random" {
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "pedram"
  length = 4
}

resource "aws_s3_bucket" "bucket" {
  bucket = random_pet.lambda_bucket_name.id
  acl    = "public-read-write"
}

module "lambda" {
  source  = "app.terraform.io/pedram-company/lambda/aws"
  version = "0.0.3"

  src_path = "${var.lambda_src_path}"
  target_path = "${var.lambda_target_path}"
}

resource "aws_api_gateway_rest_api" "restapi" {
  name = "api-carsub"
  tags = {
    "owner" = "pedram@hashicorp.com"
    "env"   = "dev"
  }
}

//new resource for restapi
resource "aws_api_gateway_resource" "apiresource" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  parent_id   = aws_api_gateway_rest_api.restapi.root_resource_id
  path_part   = "order-car"
}
//new method for the resource
resource "aws_api_gateway_method" "apimethod" {
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  resource_id   = aws_api_gateway_resource.apiresource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.restapi.id
  resource_id             = aws_api_gateway_resource.apiresource.id
  http_method             = aws_api_gateway_method.apimethod.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.lambda_invoke_arn
}

resource "aws_lambda_permission" "api_gw" {
  statement_id = "AllowExecutionFromAPIGateway"
  action       = "lambda:InvokeFunction"

  function_name = module.lambda.lambda_arn
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