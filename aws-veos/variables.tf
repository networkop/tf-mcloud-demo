variable "prefix" {
  default = "MCLOUD-POC"
}

variable "aws_prefix" {
  default = "10.123.0.0/16"
}

variable "azure_prefix" {
  default = "10.234.0.0/16"
}

variable "user_subnets" {
    type    = "list"
    default = [
        "10.123.1.0/24",
        "10.123.2.0/24"
        ]
}


variable "admin_password" {}
variable "admin_username" {}
variable "veos_license" {}
variable "ipsec_license" {}
variable "pub_ssh_key" {}