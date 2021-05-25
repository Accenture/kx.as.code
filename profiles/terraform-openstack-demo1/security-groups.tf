resource "openstack_networking_secgroup_v2" "kx_security_group" {
  name        = "kx_security_group"
  description = "KX.AS.CODE Security Group"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.kx_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.kx_security_group.id
}
