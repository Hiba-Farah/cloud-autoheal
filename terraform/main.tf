# Utiliser le réseau existant
data "openstack_networking_network_v2" "network" {
  name = "autoheal-network"
}

# VM web-1
resource "openstack_compute_instance_v2" "vm_web_1" {
  name        = "vm-web-1"
  image_name  = "cirros"
  flavor_name = "m1.tiny"
  network {
    uuid = data.openstack_networking_network_v2.network.id
  }
}

# VM web-2
resource "openstack_compute_instance_v2" "vm_web_2" {
  name        = "vm-web-2"
  image_name  = "cirros"
  flavor_name = "m1.tiny"
  network {
    uuid = data.openstack_networking_network_v2.network.id
  }
}

# VM monitor
resource "openstack_compute_instance_v2" "vm_monitor" {
  name        = "vm-monitor"
  image_name  = "cirros"
  flavor_name = "m1.tiny"
  network {
    uuid = data.openstack_networking_network_v2.network.id
  }
}
# pipeline fix
# v4 test
