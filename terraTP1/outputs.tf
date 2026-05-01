output "pokedex_public_ip" {
  description = "Adresse IP publique du serveur web"
  value       = try(aws_instance.pokedex_instance.public_ip, "")
}

output "public_instance_public_ip" {
  description = "Adresse IP publique de l'instance publique"
  value       = try(aws_instance.ssh_instance.public_ip, "")
}