provider "aws" {
  region = "eu-west-1"
}

provider "random" {
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "pedram"
  length = 4
}
# s3
resource "aws_s3_bucket" "bucket" {
  bucket = random_pet.lambda_bucket_name.id
  acl    = "public-read"
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::*/*"
            ]
        }
    ]
}
POLICY

  website {
    index_document = "index.html"
  }
  
}

resource "aws_s3_bucket_object" "file_upload" {
  for_each = fileset("${path.module}/static", "**")
    bucket = aws_s3_bucket.bucket.id
    key = each.value
    source = "${path.module}/static/${each.value}"
    etag = filemd5("${path.module}/static/${each.value}") 
}