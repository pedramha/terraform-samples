
# Output webserver IP
output "public_ip" {
  value = "http://${aws_instance.example.public_ip}:8080"
}
output "hypothetical-connectionstring" {
  value = "http://${aws_instance.example.public_ip}"
  sensitive = true
}
# output "keypair"{
#   value = tls_private_key.keypair.private_key_pem
#   sensitive = true
# }