variable "lambda_src_path" {
  type        = string
  description = "source path of lambda function"
}

variable "lambda_target_path" {
  type        = string
  description = "target path of lambda function"
}

variable "cidr_blocks" {
  type        = string
  description = "cidr block for security group"
}