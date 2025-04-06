output "instance_ips" {
  value = {
    for instance in linode_instance.wazuh_clients:
    instance.label => instance.ip_address
  }
}