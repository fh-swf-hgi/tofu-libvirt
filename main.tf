locals {
  ssh_key   = trimspace(file(pathexpand(var.ssh_public_key_file)))
  server_ip = one([for vm in var.vms : vm.ip if vm.role == "server"])

  # Welche Anwendungsdatei bekommt welche Rolle?
  app_file = {
    server = "server.py"
    client = "client.sh"
  }
}

# --- Netz ----------------------------------------------------------------------
# Ein NAT-Netz: Die VMs erreichen das Internet, sind von aussen aber nicht sichtbar.
resource "libvirt_network" "demo" {
  name      = var.network.name
  mode      = "nat"
  domain    = var.network.domain
  addresses = [var.network.cidr]
  autostart = true

  dhcp {
    enabled = true
  }

  dns {
    enabled    = true
    local_only = true
  }
}

# --- Disks ---------------------------------------------------------------------
# Das Cloud-Image wird einmal heruntergeladen ...
resource "libvirt_volume" "base" {
  name   = "demo-debian-base.qcow2"
  pool   = var.pool
  source = var.base_image
  format = "qcow2"
}

# ... und jede VM bekommt eine eigene Disk, die nur ihre Aenderungen speichert.
resource "libvirt_volume" "disk" {
  for_each = var.vms

  name           = "${each.key}.qcow2"
  pool           = var.pool
  base_volume_id = libvirt_volume.base.id
  size           = each.value.disk_gb * 1024 * 1024 * 1024
}

# --- Erstkonfiguration per cloud-init --------------------------------------------
resource "libvirt_cloudinit_disk" "init" {
  for_each = var.vms

  name = "${each.key}-cloudinit.iso"
  pool = var.pool
  user_data = templatefile("${path.module}/cloud-init/${each.value.role}.yaml.tftpl", {
    hostname  = each.key
    domain    = var.network.domain
    ssh_key   = local.ssh_key
    app_port  = var.app_port
    server_ip = local.server_ip
    app_code  = file("${path.module}/app/${local.app_file[each.value.role]}")
  })
}

# --- VMs -----------------------------------------------------------------------
resource "libvirt_domain" "vm" {
  for_each = var.vms

  name      = each.key
  vcpu      = each.value.vcpu
  memory    = each.value.memory_mb
  cloudinit = libvirt_cloudinit_disk.init[each.key].id

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.disk[each.key].id
  }

  network_interface {
    network_id     = libvirt_network.demo.id
    hostname       = each.key
    addresses      = [each.value.ip]
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
