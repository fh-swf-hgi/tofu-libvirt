output "ips" {
  description = "IP-Adressen der VMs"
  value       = { for name, vm in var.vms : name => vm.ip }
}

output "ssh" {
  description = "Anmeldung an den VMs (Standardbenutzer der Debian-Cloud-Images)"
  value       = { for name, vm in var.vms : name => "ssh debian@${vm.ip}" }
}

output "test" {
  description = "Server direkt aus dem Lab-Desktop abfragen"
  value       = "curl http://${local.server_ip}:${var.app_port}/"
}
