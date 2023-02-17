
# Output webserver IP
output "public_ip" {
  value = "http://${aws_instance.exampleb.public_ip}:8080"
}
