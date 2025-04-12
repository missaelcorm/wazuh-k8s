variable "token" {
    description = "Your Linode API Personal Access Token. (required)"
}

variable "instance_label_prefix" {
    description = "The name for the Instance"
    default = "wazuh-agent"
}

variable "instance_type" {
    description = "The Linode instance type"
    default = "g6-nanode-1"
}

variable "region" {
    description = "The default Linode region to deploy the infrastructure"
    default = "us-east"
}

variable "root_pass" {
    description = "The default root password for the Linode server"
}

variable "instance_count" {
    description = "Number of Linode instances to create"
    default = 3
}

variable "wazuh_manager" {
    description = "Wazuh Manager IP/DNS for connecting the wazuh agent"
}

variable "wazuh_registration_server" {
    description = "Wazuh Registration IP/DNS for enrolling the wazuh agent"
    default = ""
}

variable "wazuh_registration_password" {
    description = "Wazuh Registration Password for connecting the wazuh agent"
    default = "password"
}