output "tp3-2484435-multi-service_ip" {
  description = "Adresse IP publique du serveur multi service"
  value       = try(aws_instance.tp3-2484435-multi-service.public_ip, "")
}