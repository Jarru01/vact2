terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

provider "openstack" {
  user_name           = "vact4"
  tenant_name         = "vact2_4"
  password            = "vact"
  insecure            = "true"
  auth_url            = "https://158.193.152.44:5000/v3/"
  region              = "RegionOne"
  user_domain_name    = "admin_domain"
  project_domain_name = "admin_domain"

  endpoint_overrides = {
    "network"  = "https://158.193.152.44:9696/v2.0/"
    "compute"  = "https://158.193.152.44:8774/v2.1/"
    "identity" = "https://158.193.152.44:5000/v3/"
    "image"    = "https://158.193.152.44:9292/"
  }
}

variable "image" {
  type    = string
  default = "cirros"
}

variable "flavor" {
  type    = string
  default = "1c05r1d"
}

variable "network" {
  type    = string
  default = "ext-net-154"
}

resource "openstack_compute_instance_v2" "vm-terraform" {
  name        = "vm-terraform"
  image_name  = var.image
  flavor_name = var.flavor
  network {
    name = var.network
  }
}