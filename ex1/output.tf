
# Output webserver IP
output "public_ip" {
  value = "http://${aws_instance.example.public_ip}:8080"
}
