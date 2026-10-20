variable "libvirt_uri" {
  description = "Verbindung zum lokalen libvirt"
  type        = string
  default     = "qemu:///system"
}

variable "pool" {
  description = "libvirt-Storage-Pool fuer alle Disks"
  type        = string
  default     = "default"
}

variable "base_image" {
  description = "Debian-Cloud-Image (URL oder lokaler Pfad) als Basis fuer alle VMs"
  type        = string
  default     = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

variable "ssh_public_key_file" {
  description = "Oeffentlicher SSH-Schluessel, mit dem ihr euch an den VMs anmeldet"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "network" {
  description = "NAT-Netz der Demo"
  type = object({
    name   = string
    cidr   = string
    domain = string
  })
  default = {
    name   = "demo"
    cidr   = "10.20.0.0/24"
    domain = "demo.lab"
  }
}

variable "app_port" {
  description = "TCP-Port der Server-Anwendung"
  type        = number
  default     = 8080
}

variable "vms" {
  description = "Die VMs der Demo. Schluessel = Hostname, role = server oder client."
  type = map(object({
    role      = string
    ip        = string
    vcpu      = number
    memory_mb = number
    disk_gb   = number
  }))
  default = {
    server = { role = "server", ip = "10.20.0.10", vcpu = 1, memory_mb = 1024, disk_gb = 10 }
    client = { role = "client", ip = "10.20.0.20", vcpu = 1, memory_mb = 1024, disk_gb = 10 }
  }

  validation {
    condition     = alltrue([for vm in var.vms : contains(["server", "client"], vm.role)])
    error_message = "role muss \"server\" oder \"client\" sein."
  }

  validation {
    condition     = length([for vm in var.vms : vm if vm.role == "server"]) == 1
    error_message = "Die Demo erwartet genau einen Server."
  }
}
