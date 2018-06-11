# Hybric cloud orchestration with Terraform and Cloudvision Portal

Current repo contains a demo code to setup the following topology

<img src="topo.png">

This demo shows two different device provisioning models:

* AWS vEOS instance gets its IPsec configuration provisioned and pushed by CVP
* Azure vEOS instance gets its IPsec configuration pushed by Ansible

# Authentication

Terraform requires authenticaion details with enough privileges to create and delete VPC/VNET, Subnets and Virtual Machine objects
on Azure, AWS and Arista CVP. At a minimum, the folowing environment variables must be set:

```bash
export TF_VAR_ipsec_license="url to vEOS ipsec license"
export TF_VAR_veos_license="url to vEOS license"
export TF_VAR_ipsec_psk="IPsec pre-shared key"
export TF_VAR_pub_ssh_key="public ssh key"
export TF_VAR_admin_username="vEOS admin username"
export TF_VAR_admin_password="vEOS admin password"

export ARM_SUBSCRIPTION_ID="Azure subscription ID"
export ARM_CLIENT_ID="Azure client ID"
export ARM_CLIENT_SECRET="Azure client secret"
export ARM_TENANT_ID="Azure tenant ID"


export AWS_ACCESS_KEY_ID="AWS access key"
export AWS_SECRET_ACCESS_KEY="AWS secret key"
export AWS_DEFAULT_REGION="us-east-2"

export CVP_ADDRESS="CVP IP address"
export CVP_USER="CVP admin username"
export CVP_PWD="CVP admin password"
```

# Input parameters

The following list describes the meaning of all variables that are required to be specified in `terraform.tfvars`:

* **aws_cidr** - RFC1918 prefix to assign to AWS VPC
* **azure_cidr** - RFC1918 prefix to assign to Azure VNET
* **aws_asn** - BGP ASN to be assigned to vEOS in AWS
* **azure_asn** - BGP ASN to be assigned to vEOS in Azure
* **aws_tunnel_ip** - IPsec tunnel IP to be assigned to vEOS in AWS
* **azure_tunnel_ip** - IPsec tunnel IP to be assigned to vEOS in Azure
* **aws_user_subnets** - a list of user subnets to create inside AWS VPC


All remaining variables are calculated based on the one provided above.

# Building the Terraform CVP plugin

The following command assumes that the operating system is Linux x86_64

```
go get -u github.com/networkop/cvpgo
go get -u github.com/networkop/terraform-cvp
go build -o terraform.d/plugins/linux_amd64/terraform-provider-cvp github.com/networkop/terraform-cvp
```

To build it for MacOS replace the last command with

```
go build -o terraform.d/plugins/windows_amd64/terraform-provider-cvp.exe github.com/networkop/terraform-cvp
```

# Initialising Terraform

This step will ensure that all plugins required by the code are available locally and if necessary download them

```
terraform init
```

# Building the demo


```
terraform init
```

# Destroying the demo

```
terraform destroy
```