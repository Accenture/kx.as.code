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

resource "null_resource" "main_provisioner" {

  depends_on = [
    null_resource.kx_bastion_ready
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main.private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }

    inline = ["echo 'KX Main up and running'"]
  }

  provisioner "file" {
    source      = "profile-config.json"
    destination = "/var/tmp/profile-config.json"

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main.private_ip

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
      host        = aws_instance.kx_main.private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }

  }

  provisioner "file" {
    source      = "aq03-monitoring-group1.json"
    destination = "/var/tmp/aq03-monitoring-group1.json"

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main.private_ip

      bastion_user = "ec2-user"
      bastion_host = aws_instance.kx_bastion.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /var/tmp/*.json /usr/share/kx.as.code/workspace/",
      "echo \"$(date '+%Y-%m-%d_%H%M%S') | KX-Main VM created by Terraform\" | sudo tee /usr/share/kx.as.code/workspace/gogogo"

    ]
    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(local_file.kx_ssh_key.filename)
      host        = aws_instance.kx_main.private_ip

      bastion_user     = "ec2-user"
      bastion_host     = aws_instance.kx_bastion.public_ip
      bastion_host_key = file(local_file.kx_ssh_key.filename)
    }
  }
}

resource "null_resource" "worker_provisioner" {

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
