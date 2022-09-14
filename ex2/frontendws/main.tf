provider "aws" {
  region = "eu-west-1"
}

provider "random" {
}

# s3
resource "aws_s3_bucket" "bucket" {
  bucket = random.String.result
  acl    = "public-read"

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