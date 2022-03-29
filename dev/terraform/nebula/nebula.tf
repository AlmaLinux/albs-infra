variable "one_endpoint" {}
variable "one_username" {}
variable "one_template_id" {}
variable "one_image_id" {}
variable "one_network_id" {}
variable "one_password" {
  sensitive = true
}
variable "albs_ssh_key" {
  sensitive = true
}

provider "opennebula" {
  endpoint      = var.one_endpoint
  username      = var.one_username
  password      = var.one_password
}

resource "opennebula_virtual_machine" "albs_ci" {
  name = "albs_ci"
  group = "buildsys"

  cpu         = 10
  vcpu        = 10
  memory      = 10240   # 10 GB
  disk {
    image_id = tonumber(var.one_image_id)
    size     = 51201    # 50 GB
  }

  template_id = tonumber(var.one_template_id)

  nic {
    network_id = tonumber(var.one_network_id)
  }

  context = {
    NETWORK      = "YES"
    HOSTNAME     = "albs-ci.com"
    SSH_PUBLIC_KEY = var.albs_ssh_key
  }

}

output "vm_ip" {
  value = opennebula_virtual_machine.albs_ci.ip
}