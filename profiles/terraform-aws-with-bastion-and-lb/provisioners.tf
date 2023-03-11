resource "null_resource" "kx_bastion_ready" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_bastion.public_ip
    }

    inline = ["echo 'KX Bastion up and running'"]
  }

  provisioner "file" {
    source      = local_file.kx_ssh_key.filename
    destination = "/home/ec2-user/.ssh/id_rsa"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_bastion.public_ip
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_bastion.public_ip
    }

    inline = ["chmod 400 /home/ec2-user/.ssh/id_rsa"]
  }

}

resource "null_resource" "kx_main_admin_provisioner" {

  depends_on = [
    null_resource.kx_bastion_ready
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_admin.private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }

    inline = ["echo 'KX Main up and running'"]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/'$(hostname)'/kx-main1/g' /etc/hosts",
      "sudo hostnamectl set-hostname kx-main1",
      "echo \"${tls_private_key.kx_key.public_key_openssh}\" | sudo tee -a /home/kx.hero/.ssh/authorized_keys /home/admin/.ssh/authorized_keys",
      "echo \"${tls_private_key.kx_key.private_key_pem}\" | sudo tee /home/kx.hero/.ssh/id_rsa /home/admin/.ssh/id_rsa",
      "echo \"${tls_private_key.kx_key.public_key_openssh}\" | sudo tee /home/kx.hero/.ssh/id_rsa.pub /home/admin/.ssh/id_rsa.pub"
    ]

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_admin.private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }
  }

  provisioner "file" {
    source      = "profile-config.json"
    destination = "/var/tmp/profile-config.json"

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_admin.private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }
  }

  provisioner "file" {
    source      = "users.json"
    destination = "/var/tmp/users.json"

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_admin.private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }

  }

}

resource "null_resource" "kx_main_admin_action_queue_templates" {

  depends_on = [
    aws_instance.kx_main_admin,
    null_resource.kx_main_admin_provisioner
  ]

  for_each = fileset(path.module, "aq*.json")

  provisioner "file" {

    source = "${path.module}/${each.value}"
    destination = "/var/tmp/${each.value}"

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_admin.private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /var/tmp/*.json /usr/share/kx.as.code/workspace/",
      "jq '. + { \"state\": { \"kx_main1_ip_address\": \"${aws_instance.kx_main_admin.private_ip}\", \"provisioned_disks\": { \"local_storage_disk_size\": ${local.local_storage_volume_size}, \"network_storage_disk_size\": ${glusterfs_storage_volume_size} } } }' /usr/share/kx.as.code/workspace/profile-config.json >/tmp/profile-config.json && mv /tmp/profile-config.json /usr/share/kx.as.code/workspace/profile-config.json"
      "echo \"$(date '+%Y-%m-%d_%H%M%S') | KX-Main Admin VM created by Terraform\" | sudo tee /usr/share/kx.as.code/workspace/gogogo"

    ]
    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_admin.private_ip

      bastion_user     = "ec2-user"
      bastion_host     = aws_instance.kx_bastion.public_ip
      bastion_host_key = file(local_file.kx_ssh_key.filename)
    }
  }

}

resource "null_resource" "kx_worker_provisioner" {

  depends_on = [
    null_resource.kx_bastion_ready
  ]

  count = local.worker_node_count

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_worker[count.index].private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }

    inline = ["echo 'KX Worker ${count.index} up and running'"]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/'$(hostname)'/kx-worker${count.index + 1}/g' /etc/hosts",
      "sudo hostnamectl set-hostname kx-worker${count.index + 1}",
      "echo \"${tls_private_key.kx_key.public_key_openssh}\" | sudo tee -a /home/kx.hero/.ssh/authorized_keys /home/admin/.ssh/authorized_keys",
      "echo \"${tls_private_key.kx_key.private_key_pem}\" | sudo tee /home/kx.hero/.ssh/id_rsa /home/admin/.ssh/id_rsa",
      "echo \"${tls_private_key.kx_key.public_key_openssh}\" | sudo tee /home/kx.hero/.ssh/id_rsa.pub /home/admin/.ssh/id_rsa.pub"
    ]

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_worker[count.index].private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }
  }

  provisioner "file" {
    source      = "profile-config.json"
    destination = "/var/tmp/profile-config.json"

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_worker[count.index].private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }

  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /var/tmp/*.json /usr/share/kx.as.code/workspace/",
      "jq '. + { \"state\": { \"kx_main1_ip_address\": \"${aws_instance.kx_main_admin.private_ip}\", \"provisioned_disks\": { \"local_storage_disk_size\": ${local.local_storage_volume_size}, \"network_storage_disk_size\": ${glusterfs_storage_volume_size} } } }' /usr/share/kx.as.code/workspace/profile-config.json >/tmp/profile-config.json && mv /tmp/profile-config.json /usr/share/kx.as.code/workspace/profile-config.json"
      "echo \"$(date '+%Y-%m-%d_%H%M%S') | KX-Main VM created by Terraform\" | sudo tee /usr/share/kx.as.code/workspace/gogogo"
    ]
    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_worker[count.index].private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }
  }

}

resource "null_resource" "kx_main_replica" {

  depends_on = [
    null_resource.kx_bastion_ready
  ]

  count = (local.main_node_count - 1) < 0 ? 0 : local.main_node_count - 1

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_replica[count.index].private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
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
      host        = aws_instance.kx_main_replica[count.index].private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }
  }

  provisioner "file" {
    source      = "profile-config.json"
    destination = "/var/tmp/profile-config.json"

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_replica[count.index].private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }

  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /var/tmp/*.json /usr/share/kx.as.code/workspace/",
      "jq '. + { \"state\": { \"kx_main1_ip_address\": \"${aws_instance.kx_main_admin.private_ip}\", \"provisioned_disks\": { \"local_storage_disk_size\": ${local.local_storage_volume_size}, \"network_storage_disk_size\": ${glusterfs_storage_volume_size} } } }' /usr/share/kx.as.code/workspace/profile-config.json >/tmp/profile-config.json && mv /tmp/profile-config.json /usr/share/kx.as.code/workspace/profile-config.json"
      "echo \"$(date '+%Y-%m-%d_%H%M%S') | KX-Main Replica VM created by Terraform\" | sudo tee /usr/share/kx.as.code/workspace/gogogo"
    ]
    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main_replica[count.index].private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }
  }

}
