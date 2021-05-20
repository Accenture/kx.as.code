terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "vJ6JuTWiGIIbdqkmKQ8R"
  auth_url    = "http://10.2.76.201:5000/v3/"
  region      = "RegionOne"
}
