
# Output webserver IP
output "public_ip" {
  value = "http://${aws_instance.app_server.public_ip}:8080"
}
output "keypair"{
  value = tls_private_key.keypair.private_key_pem
}