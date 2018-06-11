output "veos_public_ip" {
  value = "${aws_eip.veos.public_ip}"
}

output "veos_username" {
  value = "${var.admin_username}"
}

output "veos_password" {
  value = "${var.admin_password}"
}

output "veos_private_ip" {
  value = "${aws_network_interface.veos.private_ip}"
}

output "veos_private_nh" {
  value = "${local.veos_nh}"
}

output "user_public_ips" {
  value = "${aws_instance.user.*.public_ip}"
}

output "user_subnet_prefix" {
  value = "${aws_subnet.user.*.cidr_block}"
}

output "cloud_username" {
  value = "ec2-user"
}