# Réseau interne
resource "openstack_networking_network_v2" "network" {
  name           = "autoheal-network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = "autoheal-subnet"
  network_id = openstack_networking_network_v2.network.id
  cidr       ="192.168.100.0/24"
  ip_version = 4
}

# VM web-1
resource "openstack_compute_instance_v2" "vm_web_1" {
  name            = "vm-web-1"
  image_name      = "cirros"
  flavor_name     = "m1.tiny"
  network {
    name = openstack_networking_network_v2.network.name
  }
}

# VM web-2
resource "openstack_compute_instance_v2" "vm_web_2" {
  name            = "vm-web-2"
  image_name      = "cirros"
  flavor_name     = "m1.tiny"
  network {
    name = openstack_networking_network_v2.network.name
  }
}

# VM monitor
resource "openstack_compute_instance_v2" "vm_monitor" {
  name            = "vm-monitor"
  image_name      = "cirros"
  flavor_name     = "m1.tiny"
  network {
    name = openstack_networking_network_v2.network.name
  }
}
# Pipeline CI/CD test
# test CI/CD
# test CI/CD
# CI/CD test
# trigger
