variable "prefix" {
  description = "String to prepend in front of every new created object"
  default = "MCLOUD-POC"
}
variable "resource_group" {
  description = "Existing resource group inside Azure"
}
variable "location" {
  description = "Desired location for objects and their metadata"
  default = "UK South"
}
variable "address_space" {
  description = "RFC1918 prefix to be assigned to VNET"
  default = "10.234.0.0/16"
}

variable "vm_size" {
  description = "vEOS VM size"
  default = "Standard_F2"
}

variable "admin_username" {
  description = "Admin username configured on vEOS and test VMs"
}
variable "admin_password" {
  description = "Admin password"
}
variable "pub_ssh_key" {
  description = "Public ssh key (contents of ~/.ssh/id_rsa.pub) for passwordless login"
}

variable "cloud_user" {
  description = "Default cloud user configured on vEOS (similar to AWS's ec2-user)"
  default = "ec2-user"
}

variable "peer_subnet" {
  description = "Subnet advertised from remote peer (used to setup static routes for Azure subnets)"
  default = "10.123.0.0/16"
}

variable "ipsec_license" {
  description = "vEOS IPsec license URL"
}
variable "veos_license" {
  description = "vEOS license URL"
}
variable "veos_image" {
  description = "vEOS Image details"
  type = "map"
  default = {
      publisher = "arista-networks"
      offer     = "veos-router"
      sku       = "eos-4_20_1fx-virtual-router"
      version   = "latest"
  }
}