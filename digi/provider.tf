terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
   token = var.do_token
}

data "digitalocean_ssh_key" "macmini-ssh-2" {
  name = "raju-macmini-2"
}

resource "digitalocean_droplet" "ansible_machine" {
  image = "ubuntu-20-04-x64"
  name = var.instance_name
  region = "blr1"
  size = "s-2vcpu-4gb"
  ssh_keys = [
      data.digitalocean_ssh_key.macmini-ssh-2.id
  ]
}

output "droplet_ip" {
  value = digitalocean_droplet.ansible_machine.ipv4_address
}