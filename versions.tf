terraform {
  required_version = ">= 1.6"

  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      # Bewusst festgelegt: Ab Version 0.9 hat der Provider ein komplett
      # neues Schema, die Beispiele hier gelten fuer die 0.8er-Reihe.
      version = "~> 0.8.3"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}
