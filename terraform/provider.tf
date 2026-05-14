terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
 }
}

provider "openstack" {
  auth_url    = "https://10.20.20.1:5000/v3"
  user_name   = "admin"
  password    = "GLuResExTGX1dNTM7ur05un0cHjdYSwe"
  tenant_name = "admin"
  region      = "microstack"
  insecure    = true
}
