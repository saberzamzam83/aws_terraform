output "web_server_id" {
    value = aws_instance.web_server.id
}
output "server_public_ip" {
  value = aws_eip.one.public_ip
}
output "web_server_private_ip" {
  value = aws_instance.web_server.private_ip
}