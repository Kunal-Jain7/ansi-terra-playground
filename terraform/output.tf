output "grafana_access_url" {
  value = "http://${aws_instance.client-server.public_ip}:3000"
}
