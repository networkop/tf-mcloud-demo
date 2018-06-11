/*
  This module will create all AWS objects starting from
  VPC all the way to user subnets and static routes 
*/

module "veos_aws" {
    source = "./aws-veos"

    prefix                = "MCLOUD-AWS"

    aws_prefix            = "${var.aws_cidr}"
    user_subnets          = "${var.aws_user_subnets}"
    azure_prefix          = "${var.azure_cidr}"


    veos_license          = "${var.veos_license}"
    ipsec_license         = "${var.ipsec_license}"
    pub_ssh_key           = "${var.pub_ssh_key}"
    admin_username        = "${var.admin_username}"
    admin_password        = "${var.admin_password}"
}

/*
  This module will create all Azure objects starting from
  VNET all the way to test VM
*/

module "veos_azure" {
    source = "./azure-veos"

    prefix                 = "MCLOUD-AZURE"
    resource_group        = "${var.azure_rg}"

    peer_subnet            = "${var.aws_cidr}"
    address_space          = "${var.azure_cidr}"


    veos_license          = "${var.veos_license}"
    ipsec_license         = "${var.ipsec_license}"
    pub_ssh_key           = "${var.pub_ssh_key}"
    admin_username        = "${var.admin_username}"
    admin_password        = "${var.admin_password}"
    cloud_user            = "${var.cloud_user}"
}

/*
  This resource will create an AWS-based vEOS
  as a device inside CVP and assign all the 
  necessary configlets to establish e2e IPsec connectivity
*/

resource "cvp_device" "veos_aws" {
    ip_address = "${module.veos_aws.veos_public_ip}"
    wait = "60"
    reconcile = true
    configlets = [{
        name = "${cvp_configlet.aws_ipsec.name}"
        push = true
    },{
        name = "${cvp_configlet.aws_ipsec_dest.name}"
        push = true
    }]
    depends_on = [
        "module.veos_aws", 
        "cvp_configlet.aws_ipsec", 
        "cvp_configlet.aws_ipsec_dest"
    ]
}

/*
  This resource will create an IPsec configuration
  for AWS-based vEOS device
*/

data "template_file" "aws_ipsec" {
    template = "${file("ipsec.tpl")}"

    vars {
        publicIP          = "${module.veos_aws.veos_public_ip}"
        ipsec_psk         = "${var.ipsec_psk}"
        local_tunnel_ip   = "${var.aws_tunnel_ip}"
        tunnel_source     = "${module.veos_aws.veos_private_ip}"
        local_asn         = "${var.aws_asn}"
        peer_asn          = "${var.azure_asn}"
        peer_tunnel_ip    = "${var.azure_tunnel_ip}"
        local_subnets     = "${join("!",(var.aws_user_subnets))}"
        static_nh         = "${module.veos_aws.veos_private_nh}"
    }
} 

/*
  This resource will create an IPsec configlet
  from the above IPsec configuration
*/

resource "cvp_configlet" "aws_ipsec" {
    name   = "${module.veos_aws.veos_public_ip}_IPSEC"
    config = "${data.template_file.aws_ipsec.rendered}"
}

/*
  This resource will add an IPsec tunnel destination
  config, once the Azure public IP is known
*/

data "template_file" "aws_ipsec_dest" {
    template = "interface Tunnel0\n tunnel destination $${destination}"
    vars {
        destination = "${module.veos_azure.veos_public_ip}"
    }
}

/*
  This resource will create a CVP configlet from the 
  config generated above
*/

resource "cvp_configlet" "aws_ipsec_dest" {
    name   = "${module.veos_aws.veos_public_ip}_IPSEC_DEST"
    config = "${data.template_file.aws_ipsec_dest.rendered}"
}

/*
  This resource will provision Azure-based vEOS
  device using Ansible
*/

resource "null_resource" "azure_ansible" {
    triggers {
        aws_eip = "${module.veos_azure.trigger}"
    }

    provisioner "local-exec" {
        command = "${join(" ", list(
            "ansible-playbook",
            "--extra-vars \"publicIP=${module.veos_azure.veos_public_ip}\"",
            "--extra-vars \"ipsec_psk=${var.ipsec_psk}\"",
            "--extra-vars \"local_subnet=${module.veos_azure.local_subnet}\"",
            "--extra-vars \"local_nh=${module.veos_azure.local_nh}\"",
            "--extra-vars \"tunnel_ip=${var.azure_tunnel_ip}\"",
            "--extra-vars \"tunnel_source=${module.veos_azure.veos_private_ip}\"",
            "--extra-vars \"tunnel_destination=${module.veos_aws.veos_public_ip}\"",
            "--extra-vars \"bgp_asn=${var.azure_asn}\"",
            "--extra-vars \"peer_ip=${var.aws_tunnel_ip}\"",
            "--extra-vars \"peer_asn=${var.aws_asn}\"",
            "--extra-vars \"username=${var.admin_username}\"",
            "--extra-vars \"password=${var.admin_password}\"",
            "provision.yml"  
        ))}"
    }
}
