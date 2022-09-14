
# Output s3 bucket url
output "s3_bucket_url" {
  value = "http://${aws_s3_bucket.bucket.website_endpoint}"
}