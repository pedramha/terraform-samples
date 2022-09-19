provider "aws" {
  region = "eu-west-1"
}

provider "random" {
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "pedrams"
  length = 4
}
# s3
resource "aws_s3_bucket" "bucket" {
  bucket = random_pet.lambda_bucket_name.id
  website {
    index_document = "index.html"
  }
  
}

resource "aws_s3_bucket_object" "file_upload" {
  content_type = "text/html"
  for_each = fileset("${path.module}/static", "**")
    bucket = aws_s3_bucket.bucket.id
    key = each.value
    source = "${path.module}/static/${each.value}"
    etag = filemd5("${path.module}/static/${each.value}") 
}

resource "aws_s3_bucket_acl" "site" {
  bucket = aws_s3_bucket.bucket.id

  acl = "public-read"
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject",
        Resource = [
          aws_s3_bucket.bucket.arn,
          "${aws_s3_bucket.bucket.arn}/*",
        ]
      },
    ]
  })
}

