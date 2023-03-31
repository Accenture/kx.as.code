
resource "null_resource" "kx_main_admin_provisioner" {

  depends_on = [
    aws_instance.kx_main_admin
  ]

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/'$(hostname)'/kx-main1/g' /etc/hosts",
      "sudo hostnamectl set-hostname kx-main1",
      "echo \"${tls_private_key.kx_key.public_key_openssh}\" | sudo tee -a /home/kx.hero/.ssh/authorized_keys /home/admin/.ssh/authorized_keys",
      "echo \"${tls_private_key.kx_key.private_key_pem}\" | sudo tee /home/kx.hero/.ssh/id_rsa /home/admin/.ssh/id_rsa",
      "echo \"${tls_private_key.kx_key.public_key_openssh}\" | sudo tee /home/kx.hero/.ssh/id_rsa.pub /home/admin/.ssh/id_rsa.pub",
      "sudo mkdir -p /vagrant"
    ]

    connection {
      type = "ssh"
      user = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host = aws_instance.kx_main_admin.public_ip
    }
  }
}

resource "null_resource" "kx_main_admin_profile_config" {

  depends_on = [
      null_resource.kx_main_admin_provisioner,
  ]

  provisioner "file" {
    source = "${path.module}/profile-config.json"
    destination = "/var/tmp/profile-config.json"

    connection {
      type = "ssh"
      user = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host = aws_instance.kx_main_admin.public_ip
    }
  }
}

resource "null_resource" "kx_main_admin_action_queues" {

  depends_on = [
    aws_instance.kx_main_admin,
  ]

  provisioner "file" {
    source = "${path.module}/actionQueues.json"
    destination = "/var/tmp/actionQueues.json"

    connection {
      type = "ssh"
      user = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host = aws_instance.kx_main_admin.public_ip
    }
  }
}

resource "null_resource" "kx_main_admin_users" {

  depends_on = [
    aws_instance.kx_main_admin,
  ]
  provisioner "file" {
    source = "${path.module}/users.json"
    destination = "/var/tmp/users.json"

    connection {
      type = "ssh"
      user = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host = aws_instance.kx_main_admin.public_ip
    }
  }
}

resource "null_resource" "kx_main_admin_custom_variables" {

  depends_on = [
    aws_instance.kx_main_admin,
  ]
  provisioner "file" {
    source = "${path.module}/customVariables.json"
    destination = "/var/tmp/customVariables.json"

    connection {
      type = "ssh"
      user = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host = aws_instance.kx_main_admin.public_ip
    }

  }
}

resource "null_resource" "kx_main_admin_hash" {

  depends_on = [
    aws_instance.kx_main_admin,
  ]

  provisioner "file" {
    source = "${path.module}/.hash"
    destination = "/var/tmp/.hash"

    connection {
      type = "ssh"
      user = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host = aws_instance.kx_main_admin.public_ip
    }

  }
}

resource "null_resource" "kx_main_admin_credentials" {

  depends_on = [
    aws_instance.kx_main_admin,
  ]

  provisioner "file" {
    source = "${path.module}/.vmCredentialsFile"
    destination = "/var/tmp/.vmCredentialsFile"

    connection {
      type = "ssh"
      user = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host = aws_instance.kx_main_admin.public_ip
    }

  }
}


resource "null_resource" "kx_main_admin_action_queue_templates" {

  depends_on = [
    aws_instance.kx_main_admin,
  ]

  for_each = fileset(path.module, "aq*.json")

  provisioner "file" {

    source = "${path.module}/${each.value}"
    destination = "/var/tmp/${each.value}"

    connection {
      type = "ssh"
      user = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host = aws_instance.kx_main_admin.public_ip
    }
  }
}



resource "null_resource" "kx_main_admin_custom_images" {

  depends_on = [
    aws_instance.kx_main_admin,
  ]

  for_each = fileset(path.module, "*.png")

  provisioner "file" {
    source = "${path.module}/${each.value}"
    destination = "/var/tmp/${each.value}"

    connection {
      type = "ssh"
      user = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host = aws_instance.kx_main_admin.public_ip
    }
  }
}


resource "null_resource" "kx_main_admin_property_files" {

  depends_on = [
    aws_instance.kx_main_admin,
  ]

  for_each = fileset(path.module, "properties_*.txt")

  provisioner "file" {
    source = "${path.module}/${each.value}"
    destination = "/var/tmp/${each.value}"

    connection {
      type = "ssh"
      user = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host = aws_instance.kx_main_admin.public_ip
    }
  }
}

resource "null_resource" "kx_main_admin_process_uploaded_files" {

  depends_on = [
    null_resource.kx_main_admin_action_queue_templates,
    null_resource.kx_main_admin_action_queues,
    null_resource.kx_main_admin_custom_variables,
    null_resource.kx_main_admin_hash,
    null_resource.kx_main_admin_profile_config,
    null_resource.kx_main_admin_users
  ]

  provisioner "remote-exec" {

    inline = [
      "sudo mv -f /var/tmp/*.json /usr/share/kx.as.code/workspace/",
      "jq '. + { \"state\": { \"kx_main1_ip_address\": \"${aws_instance.kx_main_admin.private_ip}\", \"provisioned_disks\": { \"local_storage_disk_size\": ${local.local_storage_volume_size}, \"network_storage_disk_size\": ${local.glusterfs_storage_volume_size} } } }' /usr/share/kx.as.code/workspace/profile-config.json >/tmp/profile-config.json && sudo mv /tmp/profile-config.json /usr/share/kx.as.code/workspace/profile-config.json",
      "sudo mv -f /var/tmp/.vmCredentialsFile /usr/share/kx.as.code/.config/",
      "sudo chmod 400 /var/tmp/.hash /usr/share/kx.as.code/.config/.vmCredentialsFile",
      "sudo mkdir -p /usr/share/kx.as.code/workspace/custom-images /vagrant/properties",
      "sudo mv -f /var/tmp/*.png /usr/share/kx.as.code/workspace/custom-images",
      "sudo chmod -R 400 /vagrant",
      "echo \"$(date '+%Y-%m-%d_%H%M%S') | KX-Main Admin VM created by Terraform\" | sudo tee /usr/share/kx.as.code/workspace/gogogo"
    ]

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_admin.public_ip
    }
  }

}

resource "null_resource" "kx_worker_provisioner" {

  depends_on = [
    aws_instance.kx_worker,
    aws_instance.kx_main_admin
  ]

  count = local.worker_node_count

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/'$(hostname)'/kx-worker${count.index + 1}/g' /etc/hosts",
      "sudo hostnamectl set-hostname kx-worker${count.index + 1}",
      "echo \"${tls_private_key.kx_key.public_key_openssh}\" | sudo tee -a /home/kx.hero/.ssh/authorized_keys /home/admin/.ssh/authorized_keys",
      "echo \"${tls_private_key.kx_key.private_key_pem}\" | sudo tee /home/kx.hero/.ssh/id_rsa /home/admin/.ssh/id_rsa",
      "echo \"${tls_private_key.kx_key.public_key_openssh}\" | sudo tee /home/kx.hero/.ssh/id_rsa.pub /home/admin/.ssh/id_rsa.pub",
      "echo \"${aws_instance.kx_main_admin.private_ip}\" | sudo tee /var/tmp/kx.as.code_main-ip-address"

    ]

    connection {
      type = "ssh"
      user = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host = aws_instance.kx_worker[count.index].public_ip
    }
  }

    provisioner "file" {
      source = "profile-config.json"
      destination = "/var/tmp/profile-config.json"

      connection {
        type = "ssh"
        user = "admin"
        private_key = file(local_file.kx_ssh_key.filename)
        host = aws_instance.kx_worker[count.index].public_ip
      }

    }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /var/tmp/*.json /usr/share/kx.as.code/workspace/",
      "jq '. + { \"state\": { \"kx_main1_ip_address\": \"${aws_instance.kx_main_admin.private_ip}\", \"provisioned_disks\": { \"local_storage_disk_size\": ${local.local_storage_volume_size}, \"network_storage_disk_size\": ${local.glusterfs_storage_volume_size} } } }' /usr/share/kx.as.code/workspace/profile-config.json >/tmp/profile-config.json && sudo mv /tmp/profile-config.json /usr/share/kx.as.code/workspace/profile-config.json",
      "echo \"$(date '+%Y-%m-%d_%H%M%S') | KX-Main VM created by Terraform\" | sudo tee /usr/share/kx.as.code/workspace/gogogo"
    ]
    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_worker[count.index].public_ip
    }
  }

}

resource "null_resource" "kx_main_replica" {

  depends_on = [
    aws_instance.kx_main_replica
  ]

  count = (local.main_node_count - 1) < 0 ? 0 : local.main_node_count - 1

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_replica[count.index].public_ip
    }

    inline = ["echo 'KX Main Replica ${count.index + 2} up and running'"]
  }

  provisioner "remote-exec" {
      inline = [
        "sudo sed -i 's/'$(hostname)'/kx-main${count.index + 2}/g' /etc/hosts",
        "sudo hostnamectl set-hostname kx-main${count.index + 2}",
        "echo \"${tls_private_key.kx_key.public_key_openssh}\" | sudo tee -a /home/kx.hero/.ssh/authorized_keys /home/admin/.ssh/authorized_keys",
        "echo \"${tls_private_key.kx_key.private_key_pem}\" | sudo tee /home/kx.hero/.ssh/id_rsa /home/admin/.ssh/id_rsa",
        "echo \"${tls_private_key.kx_key.public_key_openssh}\" | sudo tee /home/kx.hero/.ssh/id_rsa.pub /home/admin/.ssh/id_rsa.pub"
      ]

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_replica[count.index].public_ip
    }
  }

  provisioner "file" {
    source      = "profile-config.json"
    destination = "/var/tmp/profile-config.json"

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_replica[count.index].public_ip
    }

  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /var/tmp/*.json /usr/share/kx.as.code/workspace/",
      "jq '. + { \"state\": { \"kx_main1_ip_address\": \"${aws_instance.kx_main_admin.private_ip}\", \"provisioned_disks\": { \"local_storage_disk_size\": ${local.local_storage_volume_size}, \"network_storage_disk_size\": ${local.glusterfs_storage_volume_size} } } }' /usr/share/kx.as.code/workspace/profile-config.json >/tmp/profile-config.json && sudo mv /tmp/profile-config.json /usr/share/kx.as.code/workspace/profile-config.json",
      "echo \"$(date '+%Y-%m-%d_%H%M%S') | KX-Main Replica VM created by Terraform\" | sudo tee /usr/share/kx.as.code/workspace/gogogo"
    ]
    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_replica[count.index].public_ip
    }
  }

}

