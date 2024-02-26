boximage = ENV["HOME"]+"/.vagrant.d/boxes/chtrautwein-VAGRANTSLASH-kx-main/0.8.16/arm64/libvirt/box_0.img"

Vagrant.configure("2") do |config|
  # TODO: config.vm.box = "kxascode/kx-main"
  config.vm.box = "chtrautwein/kx-main"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  # See https://github.com/ppggff/vagrant-qemu
  config.vm.provider "qemu" do |v|
    v.image_path = boximage
    v.extra_qemu_args = %w(-vnc 127.0.0.1:56 -device virtio-gpu -usb -device usb-ehci -device usb-kbd -device usb-mouse -device usb-tablet -boot order=cdi,splash-time=30,menu=on)
  end
end
