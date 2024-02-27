box_version = "0.8.16"
box_url = "../boxes/qemu-"+box_version+"/kx-main-"+box_version+".box"
boximage = ENV["HOME"]+"/.vagrant.d/boxes/kxascode-VAGRANTSLASH-kx-main/"+box_version+"/arm64/libvirt/box_0.img"

Vagrant.configure("2") do |config|
  config.vm.box = "kxascode/kx-main"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  # See https://github.com/ppggff/vagrant-qemu
  config.vm.provider "qemu" do |v|
    v.image_path = boximage
    v.extra_qemu_args = %w(-vnc 127.0.0.1:56 -device virtio-gpu -usb -device usb-ehci -device usb-kbd -device usb-mouse -device usb-tablet -boot order=cdi,splash-time=30,menu=on)
  end
end
