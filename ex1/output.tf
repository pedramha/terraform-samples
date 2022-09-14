
# Output webserver IP
output "public_ip" {
  value = "http://${aws_instance.example.public_ip}:8080"
}

# Output s3 bucket url
output "s3_bucket_url" {
  value = "http://${aws_s3_bucket.bucket.website_endpoint}"
}