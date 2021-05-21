
resource "null_resource" "main_provisioner" {

  depends_on = [ openstack_compute_floatingip_associate_v2.kx-main-floating-ip-associate ]

  provisioner "file" {
    source      = "profile-config.json"
    destination = "/var/tmp/profile-config.json"

    connection {
        type     = "ssh"
        user     = "debian"
        private_key = openstack_compute_keypair_v2.kx-keypair.private_key
        host     = openstack_networking_floatingip_v2.kx-main-floating-ip.address
    }

  }

  provisioner "file" {
    source      = "aq03-monitoring-group1.json"
    destination = "/var/tmp/aq03-monitoring-group1.json"

    connection {
        type     = "ssh"
        user     = "debian"
        private_key = openstack_compute_keypair_v2.kx-keypair.private_key
        host     = openstack_networking_floatingip_v2.kx-main-floating-ip.address
    }
  }

  provisioner "file" {
    source      = "hosts_file_entries.txt"
    destination = "/var/tmp/hosts_file_entries.txt"

    connection {
        type     = "ssh"
        user     = "debian"
        private_key = openstack_compute_keypair_v2.kx-keypair.private_key
        host     = openstack_networking_floatingip_v2.kx-main-floating-ip.address
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
        private_key = openstack_compute_keypair_v2.kx-keypair.private_key
        host     = openstack_networking_floatingip_v2.kx-main-floating-ip.address
    }
  } 
}

resource "null_resource" "worker_provisioner" {

  depends_on = [ openstack_compute_floatingip_associate_v2.kx-worker-floating-ip-associate ]

  provisioner "file" {
    source      = "profile-config.json"
    destination = "/var/tmp/profile-config.json"

    connection {
        type     = "ssh"
        user     = "debian"
        private_key = openstack_compute_keypair_v2.kx-keypair.private_key
        host     = openstack_networking_floatingip_v2.kx-worker-floating-ip.address
    }

  }

  provisioner "file" {
    source      = "hosts_file_entries.txt"
    destination = "/var/tmp/hosts_file_entries.txt"

    connection {
        type     = "ssh"
        user     = "debian"
        private_key = openstack_compute_keypair_v2.kx-keypair.private_key
        host     = openstack_networking_floatingip_v2.kx-worker-floating-ip.address
    }
  }

  provisioner "remote-exec" {
    inline = [
        "sudo mv /var/tmp/*.json /usr/share/kx.as.code/workspace/",
        "cat /var/tmp/hosts_file_entries.txt | grep ${openstack_compute_instance_v2.kx-main.name} | awk {'print $1'} | sudo tee /var/tmp/kx.as.code_main-ip-address",
        "echo \"$(date '+%Y-%m-%d_%H%M%S') | KX-Main VM created by Terraform\" | sudo tee /usr/share/kx.as.code/workspace/gogogo"
    ]

    connection {
        type     = "ssh"
        user     = "debian"
        private_key = openstack_compute_keypair_v2.kx-keypair.private_key
        host     = openstack_networking_floatingip_v2.kx-worker-floating-ip.address
    }

  }

}