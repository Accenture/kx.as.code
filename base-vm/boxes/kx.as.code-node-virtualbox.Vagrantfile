Vagrant.configure("2") do |config|
  config.vm.define "kx.as.code-worker" do |subconfig|
    subconfig.vm.box = "kx.as.code-worker-virtualbox"
    subconfig.vm.box_url = "../boxes/virtualbox/kx.as.code-worker-virtualbox.box"
    subconfig.vm.synced_folder "c:/Users/Patrick/KX_Share", "/home/kx.hero/KX_Share",
      owner: "kx.hero", group: "kx.hero"
    subconfig.vm.provider "virtualbox" do |v|
      v.name = "kx.as.code-worker"
      v.customize ["modifyvm", :id, "--memory", "8192"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
    end
  end
end
