locals {
  raw_version = jsondecode(file("../../../../versions.json"))
  version  = local.raw_version.kxascode
  kube_version = local.raw_version.kubernetes
}

variable "domain" {
  type    = string
  default = "kx-as-code.local"
}

variable "compute_engine_build" {
  type    = string
  default = "false"
}

variable "base_image_ssh_user" {
  type    = string
  default = "vagrant"
}

variable "vm_user" {
  type    = string
  default = "kx.hero"
}

variable "vm_password" {
  type    = string
  default = "L3arnandshare"
}

variable "disable_ipv6" {
  type    = string
  default = "true"
}

variable "disk_size" {
  type    = string
  default = "153600"
}

variable "guest_additions_checksum" {
  type    = string
  default = "b37f6aabe5a32e8b96ccca01f37fb49f4fd06674f1b29bc8fe0f423ead37b917"
}

variable "guest_additions_url" {
  type    = string
  default = "https://download.virtualbox.org/virtualbox/7.0.12/VBoxGuestAdditions_7.0.12.iso"
}

variable "headless" {
  type    = string
  default = "true"
}

variable "hostname" {
  type    = string
  default = "kx-node"
}

variable "http_bind_address" {
  type    = string
  default = "0.0.0.0"
}

variable "http_directory" {
  type    = string
  default = "./http"
}

variable "http_port_max" {
  type    = string
  default = "8099"
}

variable "http_port_min" {
  type    = string
  default = "8090"
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "iso_checksum" {
  type    = string
  default = "d7a74813a734083df30c8d35784926deaa36bc41e5c0766388e9f591ab056b72"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_file" {
  type    = string
  default = "debian-11.8.0-amd64-netinst.iso"
}

variable "iso_path" {
  type    = string
  default = "iso"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.debian.org/cdimage/archive/11.8.0/amd64/iso-cd/debian-11.8.0-amd64-netinst.iso"
}

variable "kx_home" {
  type    = string
  default = "/usr/share/kx.as.code"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "parallels_guest_os_type" {
  type    = string
  default = "linux-2.6"
}

variable "parallels_tools_flavor" {
  type    = string
  default = "lin"
}

variable "parallels_tools_guest_path" {
  type    = string
  default = "/var/tmp/prl-tools-lin.iso"
}

variable "parallels_tools_mode" {
  type    = string
  default = "upload"
}

variable "preseed_path" {
  type    = string
  default = "preseed-main.cfg"
}

variable "shutdown_command" {
  type    = string
  default = "echo 'halt -p' > shutdown.sh; echo 'vagrant'|sudo -S sh 'shutdown.sh'"
}

variable "ssh_fullname" {
  type    = string
  default = "KX Hero"
}

variable "update" {
  type    = string
  default = "true"
}

variable "vbox_guest_additions_deb_checksum" {
  type    = string
  default = ""
}

variable "vbox_guest_additions_deb_url" {
  type    = string
  default = ""
}

variable "memory" {
  type    = string
  default = "8192"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "video_memory" {
  type    = string
  default = "128"
}

variable "virtualbox_guest_os_type" {
  type    = string
  default = "Debian_64"
}

variable "vm_name" {
  type    = string
  default = "kx-node"
}

variable "vmware_guest_os_type" {
  type    = string
  default = "ubuntu64Guest"
}

locals {
  boot_command = "<esc><wait>install <wait> preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}//${ var.preseed_path} <wait>debian-installer=en_US.UTF-8 <wait>auto <wait>locale=en_US.UTF-8 <wait>kbd-chooser/method=de <wait>keyboard-configuration/xkb-keymap=de <wait>netcfg/get_hostname={{ .Name }} <wait>netcfg/get_domain=vagrantup.com <wait>fb=false <wait>debconf/frontend=noninteractive <wait>console-setup/ask_detect=false <wait>console-keymaps-at/keymap=us <wait>grub-installer/bootdev=/dev/sda <wait><enter><wait>"
}

source "parallels-iso" "kx-node-parallels" {
  boot_command               = [ "${ local.boot_command }{{.HTTPIP}}:{{.HTTPPort}}// ${ var.preseed_path }<wait> , --- <enter>" ]
  boot_wait                  = "1s"
  disk_size                  = var.disk_size
  guest_os_type              = var.parallels_guest_os_type
  hard_drive_interface       = "sata"
  http_directory             = "http"
  iso_checksum               = "${ var.iso_checksum_type }:${ var.iso_checksum}"
  iso_urls                   = [ "${ var.iso_path }/ ${ var.iso_file}", var.iso_url ]
  output_directory           = "../../../output-main/parallels-${ local.version }"
  parallels_tools_flavor     = var.parallels_tools_flavor
  parallels_tools_guest_path = var.parallels_tools_guest_path
  parallels_tools_mode       = var.parallels_tools_mode
  prlctl                     = [
    ["set", "{{.Name}}", "--memsize", var.memory],
    ["set", "{{.Name}}", "--cpus", var.cpus],
    ["set", "{{.Name}}", "--distribution", var.parallels_guest_os_type],
    ["set", "{{.Name}}", "--videosize", var.video_memory],
    ["set", "{{.Name}}", "--3d-accelerate", "highest"],
    ["set", "{{.Name}}", "--high-resolution", "off"],
    ["set", "{{.Name}}", "--high-resolution-in-guest", "off"],
    ["set", "{{.Name}}", "--auto-share-camera", "off"],
    ["set", "{{.Name}}", "--auto-share-bluetooth", "off"],
    ["set", "{{.Name}}", "--on-window-close", "keep-running"],
    ["set", "{{.Name}}", "--startup-view", "same"],
    ["set", "{{.Name}}", "--on-shutdown", "close"]
  ]
  shutdown_command           = var.shutdown_command
  ssh_password               = "vagrant"
  ssh_port                   = 22
  ssh_username               = "vagrant"
  ssh_wait_timeout           = "3600s"
  vm_name                    = "kx-node-${ local.version }"
}

source "virtualbox-iso" "kx-node-virtualbox" {
  boot_command            = [
    "<esc><wait>",
    "install <wait>",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${ var.preseed_path } <wait>",
    "debian-installer=en_US.UTF-8 <wait>", "auto <wait>", "locale=en_US.UTF-8 <wait>",
    "kbd-chooser/method=us <wait>",
    "keyboard-configuration/xkb-keymap=us <wait>",
    "netcfg/get_hostname=${ var.hostname } <wait>",
    "netcfg/get_domain=${ var.domain } <wait>",
    "fb=false <wait>",
    "debconf/frontend=noninteractive <wait>",
    "console-setup/ask_detect=false <wait>",
    "console-keymaps-at/keymap=us <wait>",
    "grub-installer/bootdev=/dev/sda <wait>",
    "<enter><wait>"]
  boot_wait               = "10s"
  disk_size               = var.disk_size
  format                  = "ova"
  guest_additions_mode    = "upload"
  guest_additions_path    = "/home/vagrant/VBoxGuestAdditions_{{.Version}}.iso"
  guest_additions_sha256  = var.guest_additions_checksum
  guest_additions_url     = var.guest_additions_url
  guest_os_type           = var.virtualbox_guest_os_type
  hard_drive_interface    = "sata"
  headless                = true
  http_directory          = "http"
  iso_checksum            = "${ var.iso_checksum_type }:${ var.iso_checksum}"
  iso_urls                = [ "${ var.iso_path }/${ var.iso_file}", var.iso_url ]
  output_directory        = "../../../output-main/virtualbox-${ local.version }"
  post_shutdown_delay     = "30s"
  shutdown_command        = var.shutdown_command
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_username            = "vagrant"
  ssh_wait_timeout        = "3600s"
  vboxmanage              = [
    ["modifyvm", "{{.Name}}", "--audio", "none"],
    ["modifyvm", "{{.Name}}", "--usb", "off"],
    ["modifyvm", "{{.Name}}", "--graphicscontroller", "vmsvga"],
    ["modifyvm", "{{.Name}}", "--accelerate3d", "off"],
    ["modifyvm", "{{.Name}}", "--vram", var.video_memory],
    ["modifyvm", "{{.Name}}", "--vrde", "off"], ["modifyvm", "{{.Name}}", "--memory", var.memory],
    ["modifyvm", "{{.Name}}", "--cpus", var.cpus],
    ["modifyvm", "{{.Name}}", "--clipboard", "bidirectional"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"]
  ]
  vboxmanage_post         = [
    ["setextradata", "{{.Name}}", "CustomVideoMode1", "1920x1200x32"],
    ["modifyvm", "{{.Name}}", "--nic1", "natnetwork", "--natnetwork1", "kxascode"]
  ]
  virtualbox_version_file = "VBoxVersion.txt"
  vm_name                 = "kx-node-${ local.version }"
  vrdp_bind_address       = "127.0.0.1"
  vrdp_port_max           = 12000
  vrdp_port_min           = 11000
}

source "vmware-iso" "kx-node-vmware-desktop" {
  boot_command      = [
    "<esc><wait>",
    "install <wait>",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${ var.preseed_path } <wait>",
    "debian-installer=en_US.UTF-8 <wait>",
    "auto <wait>",
    "locale=en_US.UTF-8 <wait>",
    "kbd-chooser/method=us <wait>",
    "keyboard-configuration/xkb-keymap=us <wait>",
    "netcfg/get_hostname=${ var.hostname } <wait>",
    "netcfg/get_domain=${ var.domain } <wait>",
    "fb=false <wait>",
    "debconf/frontend=noninteractive <wait>",
    "console-setup/ask_detect=false <wait>",
    "console-keymaps-at/keymap=us <wait>",
    "grub-installer/bootdev=/dev/sda <wait>",
    "<enter><wait>"
  ]
  boot_wait         = "10s"
  disk_size         = var.disk_size
  guest_os_type     = var.vmware_guest_os_type
  http_bind_address = var.http_bind_address
  http_directory    = "http"
  http_port_max     = var.http_port_max
  http_port_min     = var.http_port_min
  iso_checksum      = "${ var.iso_checksum_type }:${ var.iso_checksum}"
  iso_urls          = [ "${ var.iso_path }/${ var.iso_file }", var.iso_url ]
  network           = "nat"
  output_directory  = "../../../output-main/vmware-desktop-${ local.version }"
  shutdown_command  = var.shutdown_command
  ssh_password      = "vagrant"
  ssh_port          = 22
  ssh_timeout       = "3600s"
  ssh_username      = "vagrant"
  vm_name           = "kx-node-${ local.version }"
  vmx_data = {
    "isolation.tools.hgfs.disable" = "FALSE"
    memsize                        = var.memory
    numvcpus                       = var.cpus
  }
}

build {
  sources = [
    "source.parallels-iso.kx-node-parallels",
    "source.virtualbox-iso.kx-node-virtualbox",
    "source.vmware-iso.kx-node-vmware-desktop"
  ]

  provisioner "shell" {
    environment_vars    = [
      "VM_USER=${ var.vm_user }",
      "VM_PASSWORD=${ var.vm_password }",
      "KX_HOME=${ var.kx_home }",
      "SKELDIR=${ var.kx_home }/skel",
      "SHARED_GIT_REPOSITORIES=${ var.kx_home }/git",
      "INSTALLATION_WORKSPACE=${ var.kx_home }/workspace"]
    expect_disconnect   = "true"
    scripts             = [
      "../../../scripts/base/directories.sh",
      "../../../scripts/base/vagrant-user.sh",
      "../../../scripts/base/kx-user.sh",
      "../../../scripts/base/update.sh"
    ]
    start_retry_timeout = "15m"
  }

  provisioner "shell" {
    environment_vars = [
      "VM_USER=${ var.vm_user }",
      "VBOX_GUEST_ADDITIONS_DEB_URL=${ var.vbox_guest_additions_deb_url }",
      "VBOX_GUEST_ADDITIONS_DEB_CHECKSUM=${ var.vbox_guest_additions_deb_checksum}"
    ]
    only             = ["kx-node-virtualbox"]
    script           = "../../../scripts/base/virtualbox.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "PARALLELS_TOOLS_GUEST_PATH=${ var.parallels_tools_guest_path }"
    ]
    only             = ["kx-node-parallels"]
    script           = "../../../scripts/base/parallels.sh"
  }

  provisioner "shell" {
    only   = ["kx-node-vmware-desktop"]
    script = "../../../scripts/base/vmware.sh"
  }

  provisioner "shell" {
    expect_disconnect   = "true"
    pause_before        = "1m0s"
    scripts             = [
      "../../../scripts/base/cleanup.sh",
      "../../../scripts/base/localtime.sh",
      "../../../scripts/base/power.sh",
      "../../../scripts/base/network.sh"
    ]
    start_retry_timeout = "15m"
  }

  provisioner "file" {
    destination = "${ var.kx_home }"
    source      = "../../../dependencies/skel"
  }

  provisioner "file" {
    destination = "${ var.kx_home }/workspace/theme"
    source      = "../../../dependencies/theme"
  }

  provisioner "file" {
    destination = "${var.kx_home}/workspace/scripts"
    source      = "../../../scripts/cluster-node"
  }

  provisioner "file" {
    destination = "${ var.kx_home }/workspace/versions.json"
    source      = "../../../../versions.json"
  }

  provisioner "file" {
    destination = "${var.kx_home}/workspace/globalVariables.json"
    source      = "../../../../auto-setup/globalVariables.json"
  }

  provisioner "shell" {
    environment_vars    = [
      "BASE_IMAGE_SSH_USER=${ var.base_image_ssh_user }",
      "VM_USER=${ var.vm_user }",
      "VM_PASSWORD=${ var.vm_password }",
      "VERSION=${ local.version }",
      "KUBE_VERSION=${ local.kube_version }",
      "COMPUTE_ENGINE_BUILD=${ var.compute_engine_build }",
      "KX_HOME=${ var.kx_home }",
      "SKELDIR=${ var.kx_home }/skel",
      "INSTALLATION_WORKSPACE=${ var.kx_home }/workspace"
    ]
    expect_disconnect   = "true"
    pause_before        = "1m0s"
    scripts             = [
      "../../../scripts/common/motd.sh",
      "../../../scripts/common/kx.as.code.sh",
      "../../../scripts/common/tools.sh",
      "../../../scripts/common/docker.sh",
      "../../../scripts/common/calico.sh"
    ]
    start_retry_timeout = "15m"
  }

  provisioner "shell" {
    environment_vars    = [
      "BASE_IMAGE_SSH_USER=${ var.base_image_ssh_user }",
      "VM_USER=${ var.vm_user }",
      "VM_PASSWORD=${ var.vm_password }",
      "VERSION=${ local.version }",
      "KX_HOME=${ var.kx_home }",
      "SKELDIR=${ var.kx_home }/skel",
      "SHARED_GIT_REPOSITORIES=${ var.kx_home }/git",
      "INSTALLATION_WORKSPACE=${ var.kx_home }/workspace",
      "COMPUTE_ENGINE_BUILD=${ var.compute_engine_build }"
    ]
    expect_disconnect   = "true"
    pause_before        = "1m0s"
    scripts             = [
      "../../../scripts/cluster-node/tools.sh",
      "../../../scripts/cluster-node/k8s-base.sh",
      "../../../scripts/cluster-node/cleanup.sh"
    ]
    start_retry_timeout = "15m"
  }

  post-processor "manifest" {
    custom_data = {
      version = "${ local.version }"
    }
    output = "kx-node-${ local.version }_manifest.json"
  }
  post-processor "shell-local" {
    environment_vars = ["VM_VERSION=${ local.version }", "VM_NAME=kx-node"]
    execute_command  = ["bash", "-c", "{{ .Vars }} {{ .Script }}"]
    only_on          = ["darwin", "linux"]
    script           = "../../../scripts/post-processing/create-info-json.sh"
  }
  post-processor "vagrant" {
    keep_input_artifact  = true
    include              = ["../../../boxes/virtualbox-${ local.version }/info.json", "kx-node-${ local.version }_manifest.json"]
    only                 = ["kx-node-virtualbox"]
    output               = "../../../boxes/{{ .Provider }}-${ local.version }/kx-node-${ local.version }.box"
    vagrantfile_template = "../../../boxes/kx.as.code-main-virtualbox.Vagrantfile"
  }
  post-processor "vagrant" {
    keep_input_artifact  = true
    include              = ["../../../boxes/parallels-${ local.version }/info.json", "kx-node-${ local.version }_manifest.json"]
    only                 = ["kx-node-parallels"]
    output               = "../../../boxes/{{ .Provider }}-${ local.version }/kx-node-${ local.version }.box"
    vagrantfile_template = "../../../boxes/kx.as.code-main-parallels.Vagrantfile"
  }
  post-processor "vagrant" {
    keep_input_artifact  = true
    include              = ["../../../boxes/vmware-desktop-${ local.version }/info.json", "kx-node-${ local.version }_manifest.json"]
    only                 = ["kx-node-vmware-desktop"]
    output               = "../../../boxes/vmware-desktop-${ local.version }/kx-node-${ local.version }.box"
    vagrantfile_template = "../../../boxes/kx.as.code-main-vmware.Vagrantfile"
  }
  post-processor "shell-local" {
    environment_vars = ["VM_VERSION=${ local.version }", "VM_NAME=kx-node"]
    execute_command  = ["bash", "-c", "{{ .Vars }} {{ .Script }}"]
    only_on          = ["darwin", "linux"]
    script           = "../../../scripts/post-processing/move-manifest-json.sh"
  }
  post-processor "shell-local" {
    environment_vars = ["VM_VERSION=${ local.version }", "VM_NAME=kx-node"]
    only             = ["kx-node-vmware-desktop"]
    only_on          = ["darwin", "linux"]
    script           = "../../../scripts/post-processing/export-vmware-ova.sh"
  }
  post-processor "shell-local" {
    environment_vars = ["VM_VERSION=${ local.version }", "VM_NAME=kx-node"]
    execute_command  = ["bash", "-c", "{{ .Vars }} {{ .Script }}"]
    only_on          = ["darwin", "linux"]
    scripts          = ["../../../scripts/post-processing/create-metadata-json.sh", "../../../scripts/post-processing/add-vagrant-box.sh"]
  }
}
