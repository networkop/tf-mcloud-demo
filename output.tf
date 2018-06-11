output "aws_veos" {
  value = "${var.cloud_user}@${module.veos_aws.veos_public_ip}"
}

output "azure_veos" {
  value = "${var.cloud_user}@${module.veos_azure.veos_public_ip}"
}

output "aws_user_public_ips" {
  value = "${join("", formatlist("\ncentos@%s", module.veos_aws.user_public_ips))}"
}

output "azure_test_vm" {
  value = "${var.cloud_user}@${module.veos_azure.test_vm_public_ip}"
}

output "veos_username" {
  value = "${module.veos_aws.veos_username}"
}

output "veos_password" {
  value = "${module.veos_aws.veos_password}"
}

output "aws_user_subnets" {
  value = "${var.aws_user_subnets}"
}

output "azure_user_subnets" {
  value = "${module.veos_azure.local_subnet}"
}
