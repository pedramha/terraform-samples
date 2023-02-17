
# Output webserver IP
output "public_ip" {
  value = "http://${aws_instance.app_server.public_ip}:8080"
}
