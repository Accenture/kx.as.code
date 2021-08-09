
resource "null_resource" "main_admin_provisioner" {

  depends_on = [
    openstack_compute_floatingip_associate_v2.kx_main_admin_floating_ip_associate
  ]

  provisioner "file" {
    source = "profile-config.json"
    destination = "/var/tmp/profile-config.json"

    connection {
      type = "ssh"
      user = "debian"
      private_key = openstack_compute_keypair_v2.kx_keypair.private_key
      host = openstack_networking_floatingip_v2.kx_main_admin_floating_ip.address
    }

  }

  provisioner "file" {
    source = "users.json"
    destination = "/var/tmp/users.json"

    connection {
      type = "ssh"
      user = "debian"
      private_key = openstack_compute_keypair_v2.kx_keypair.private_key
      host = openstack_networking_floatingip_v2.kx_main_admin_floating_ip.address
    }

  }
}

resource "null_resource" "kx_main_qa_provisioner" {

  depends_on = [
    openstack_compute_floatingip_associate_v2.kx_main_admin_floating_ip_associate
  ]

  for_each = fileset(path.module, "aq*.json")

  provisioner "file" {
    source = each.value
    destination = "/var/tmp/${each.value}"

    connection {
      type = "ssh"
      user = "debian"
      private_key = openstack_compute_keypair_v2.kx_keypair.private_key
      host = openstack_networking_floatingip_v2.kx_main_admin_floating_ip.address
    }
  }
}

resource "null_resource" "kx_main_final_provisioner" {

  depends_on = [
    openstack_compute_floatingip_associate_v2.kx_main_admin_floating_ip_associate,
    null_resource.main_admin_provisioner,
    null_resource.kx_main_qa_provisioner
  ]

  provisioner "file" {
    source      = "hosts_file_entries.txt"
    destination = "/var/tmp/hosts_file_entries.txt"

    connection {
        type     = "ssh"
        user     = "debian"
        private_key = openstack_compute_keypair_v2.kx_keypair.private_key
        host     = openstack_networking_floatingip_v2.kx_main_admin_floating_ip.address
    }
  }

  provisioner "remote-exec" {
    inline = [
        "sudo mv /var/tmp/*.json /usr/share/kx.as.code/workspace/",
        "echo \"$(date '+%Y-%m-%d_%H%M%S') | KX-Main VM created by Terraform\" | sudo tee /usr/share/kx.as.code/workspace/gogogo"
        
    ]
    connection {
        type     = "ssh"
        user     = "debian"
        private_key = openstack_compute_keypair_v2.kx_keypair.private_key
        host     = openstack_networking_floatingip_v2.kx_main_admin_floating_ip.address
    }
  } 
}

resource "null_resource" "main_replica_provisioner" {

  depends_on = [
    openstack_compute_floatingip_associate_v2.kx_main_replica_floating_ip_associate
  ]

  count = (local.main_node_count - 1) < 0 ? 0 : local.main_node_count - 1

  provisioner "file" {
    source = "profile-config.json"
    destination = "/var/tmp/profile-config.json"

    connection {
      type = "ssh"
      user = "debian"
      private_key = openstack_compute_keypair_v2.kx_keypair.private_key
      host = element(openstack_networking_floatingip_v2.kx_main_replica_floating_ip.*.address, count.index)
    }

  }

  provisioner "file" {
    source = "hosts_file_entries.txt"
    destination = "/var/tmp/hosts_file_entries.txt"

    connection {
      type = "ssh"
      user = "debian"
      private_key = openstack_compute_keypair_v2.kx_keypair.private_key
      host = element(openstack_networking_floatingip_v2.kx_main_replica_floating_ip.*.address, count.index)
    }
  }
}

resource "null_resource" "main_replica_final_provisioner" {

  depends_on = [
    openstack_compute_floatingip_associate_v2.kx_main_replica_floating_ip_associate,
    null_resource.main_replica_provisioner
  ]

  count = (local.main_node_count - 1) < 0 ? 0 : local.main_node_count - 1

  provisioner "remote-exec" {
    inline = [
      "sudo mv /var/tmp/*.json /usr/share/kx.as.code/workspace/",
      "cat /var/tmp/hosts_file_entries.txt | grep ${openstack_compute_instance_v2.kx_main_admin.name} | awk {'print $1'} | sudo tee /var/tmp/kx.as.code_main-ip-address",
      "echo \"$(date '+%Y-%m-%d_%H%M%S') | KX-Main VM created by Terraform\" | sudo tee /usr/share/kx.as.code/workspace/gogogo"
    ]

    connection {
      type     = "ssh"
      user     = "debian"
      private_key = openstack_compute_keypair_v2.kx_keypair.private_key
      host     = element(openstack_networking_floatingip_v2.kx_main_replica_floating_ip.*.address, count.index)
    }

  }

}

resource "null_resource" "worker_provisioner" {

  depends_on = [
    openstack_compute_floatingip_associate_v2.kx_worker_floating_ip_associate
  ]

  count = local.worker_node_count

  provisioner "file" {
    source = "profile-config.json"
    destination = "/var/tmp/profile-config.json"

    connection {
      type = "ssh"
      user = "debian"
      private_key = openstack_compute_keypair_v2.kx_keypair.private_key
      host = element(openstack_networking_floatingip_v2.kx_worker_floating_ip.*.address, count.index)
    }

  }

  provisioner "file" {
    source = "hosts_file_entries.txt"
    destination = "/var/tmp/hosts_file_entries.txt"

    connection {
      type = "ssh"
      user = "debian"
      private_key = openstack_compute_keypair_v2.kx_keypair.private_key
      host = element(openstack_networking_floatingip_v2.kx_worker_floating_ip.*.address, count.index)
    }
  }
}

resource "null_resource" "worker_final_provisioner" {

  depends_on = [
    openstack_compute_floatingip_associate_v2.kx_worker_floating_ip_associate,
    null_resource.worker_provisioner
  ]

  count = local.worker_node_count

  provisioner "remote-exec" {
    inline = [
        "sudo mv /var/tmp/*.json /usr/share/kx.as.code/workspace/",
        "cat /var/tmp/hosts_file_entries.txt | grep ${openstack_compute_instance_v2.kx_main_admin.name} | awk {'print $1'} | sudo tee /var/tmp/kx.as.code_main-ip-address",
        "echo \"$(date '+%Y-%m-%d_%H%M%S') | KX-Main VM created by Terraform\" | sudo tee /usr/share/kx.as.code/workspace/gogogo"
    ]

    connection {
        type     = "ssh"
        user     = "debian"
        private_key = openstack_compute_keypair_v2.kx_keypair.private_key
        host     = element(openstack_networking_floatingip_v2.kx_worker_floating_ip.*.address, count.index)
    }

  }

}