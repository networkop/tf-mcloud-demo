variable "aws_tunnel_ip" {
}
variable "azure_tunnel_ip" {
}
variable "aws_asn" {
}
variable "azure_asn" {
}
variable "aws_cidr" {
}
variable "aws_user_subnets" {
    type    = "list"
}
variable "azure_cidr" {
}

variable "cloud_user" {}
variable "admin_password" {}
variable "admin_username" {}
variable "veos_license" {}
variable "ipsec_license" {}
variable "pub_ssh_key" {}
variable "ipsec_psk" {}