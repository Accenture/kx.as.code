Vagrant.configure("2") do |config|
  config.vm.define "kx.as.code-main" do |subconfig|
    subconfig.vm.box = "kx.as.code-main-virtualbox"
    subconfig.vm.box_url = "../boxes/virtualbox/kx.as.code-main-virtualbox.box"
    subconfig.vm.synced_folder "c:/Users/Patrick/KX_Share", "/home/kx.hero/KX_Share",
      owner: "kx.hero", group: "kx.hero"
    subconfig.vm.provider "virtualbox" do |v|
      v.name = "kx.as.code-main"
      v.customize ["modifyvm", :id, "--memory", "8192"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
      v.customize ["modifyvm", :id, "--accelerate3d", "off"]
      v.customize ["modifyvm", :id, "--vram", "128"]
    end
  end
end
