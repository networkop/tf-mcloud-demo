
output "veos_public_ip" {
  value = "${data.azurerm_public_ip.main.ip_address}"
}

output "veos_private_ip" {
  value = "${data.azurerm_network_interface.veos.private_ip_address}"
}

output "veos_username" {
  value = "${var.admin_username}"
}

output "veos_password" {
  value = "${var.admin_password}"
}

output "local_subnet" {
  value = "${local.test_subnet}"
}

output "local_nh" {
  value = "${local.veos_nh}"
}

output "test_vm_public_ip" {
  value = "${azurerm_public_ip.local_test.ip_address}"
}

output "trigger" {
  value = "${azurerm_virtual_machine.veos.id}"
}