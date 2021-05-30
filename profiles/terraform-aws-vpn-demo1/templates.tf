data "template_file" "init-main" {
  template = file("./init-main.tpl")
  vars = {
    aws_access_key_id    = var.ACCESS_KEY
    secret_access_key_id = var.SECRET_KEY
    hostname             = "kx-main"
  }
}

data "template_file" "init-worker" {
  template = file("./init-worker.tpl")
  count    = var.NUM_KX_WORKER_NODES
  vars = {
    aws_access_key_id    = var.ACCESS_KEY
    secret_access_key_id = var.SECRET_KEY
    hostname             = "kx-worker${count.index + 1}"
    kx_main_private_ip   = aws_instance.kx-main.private_ip
  }
}

data "template_cloudinit_config" "config-main" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.init-main.rendered
  }
}

data "template_cloudinit_config" "config-worker" {
  gzip          = true
  base64_encode = true
  count         = var.NUM_KX_WORKER_NODES
  # Main cloud-config configuration file.
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.init-worker[count.index].rendered
  }
}
