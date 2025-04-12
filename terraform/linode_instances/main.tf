terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "2.7.1"
    }
  }
}

provider "linode" {
  token = var.token
}

resource "linode_instance" "wazuh_clients" {
  count = var.instance_count
  
  image = "linode/ubuntu24.04"
  label = "${var.instance_label_prefix}-${count.index + 1}"
  region = var.region
  type = var.instance_type
  swap_size = 1024
  root_pass = var.root_pass

  tags = ["wazuh-agents", "terraform"]

  metadata {
    user_data = base64encode(templatefile("${path.module}/scripts/user_data.tftpl", {
      WAZUH_MANAGER = var.wazuh_manager,
      WAZUH_REGISTRATION_SERVER = var.wazuh_registration_server == "" ? var.wazuh_manager : var.wazuh_registration_server,
      WAZUH_REGISTRATION_PASSWORD = var.wazuh_registration_password,
      WAZUH_AGENT_NAME = "${var.instance_label_prefix}-${count.index + 1}"
    }))
  }
}
