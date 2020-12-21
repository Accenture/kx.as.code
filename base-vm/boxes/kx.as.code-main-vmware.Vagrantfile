#################################################################################################################
#                                                                                                               #
#  Use this file for creating the vagrantfile after a packer build.                                             #
#                                                                                                               #
#  Command Example:                                                                                             #
#  $ vagrant init z2h-kx-as-code-1.1.4 z2h-kx-as-code-1.1.4.box --template ../../z2h_kx.as.code.erb             #
#                                                                                                               #
#################################################################################################################

Vagrant.configure("2") do |config|
  config.vm.box = "kx.as.code-main"
  config.vm.box_url = "../boxes/vmware/kx.as.code-main-vmware.box"
  config.vm.provider "vmware_desktop" do |v|
    v.gui = true
    v.whitelist_verified = true
    v.vmx['displayname'] = 'kx.as.code'
    v.vmx["memsize"] = "16384"
    v.vmx["numvcpus"] = "2"
    v.vmx["mks.enable3d"] = "FALSE"
    v.vmx["ethernet0.pcislotnumber"] = "33"
    v.vmx["sound.startconnected"] = "FALSE"
    v.vmx["sound.present"] = "FALSE"
  end
end
