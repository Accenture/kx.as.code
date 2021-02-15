#!/bin/bash -eux
set -o pipefail

sudo apt-get install -y dnsmasq

if [[ "$PACKER_BUILDER_TYPE" =~ "virtualbox" ]]; then
    # Get network device name
    NET_DEVICE=$(nmcli device status | grep ethernet | grep enp | awk {'print $1'})

    # Change DNS resolution to allow wildcards for resolving locally deployed K8s services
    echo "DNSStubListener=no" | sudo tee -a /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved
    sudo rm -f /etc/resolv.conf

    # Avoid Network Manager updating resolv.conf
    sudo sed -i '/^\[main\]/a dns=none' /etc/NetworkManager/NetworkManager.conf

    # Create resolv.conf for desktop user with 127.0.0.1 for dnsmasq for resolving *.kx-as-code.com
    sudo bash -c 'cat <<EOF > /etc/resolv.conf
    # File Generated During KX.AS.CODE VM Packer Build Process
    nameserver '$IP_ADDRESS'
    nameserver 8.8.8.8
    EOF'

    # Configue dnsmasq - /etc/resolv.conf
    sudo sed -i 's/^#nameserver 127.0.0.1/nameserver '$IP_ADDRESS'/g' /etc/resolv.conf
    sudo sed -i 's/^#no-resolv/no-resolv/' /etc/dnsmasq.conf
    sudo sed -i 's/^#interface=/interface='$NET_DEVICE'/' /etc/dnsmasq.conf
    sudo sed -i 's/^#bind-interfaces/bind-interfaces/' /etc/dnsmasq.conf
    sudo sed -i 's/^#listen-address=/listen-address=::1,127.0.0.1,'$IP_ADDRESS'/' /etc/dnsmasq.conf
    # Configue dnsmasq - /lib/systemd/system/dnsmasq.service (bugfix so dnsmasq starts automatically)
    sudo sed -i 's/Wants=nss-lookup.target/Wants=network-online.target/' /lib/systemd/system/dnsmasq.service
    sudo sed -i 's/After=network.target/After=network-online.target/' /lib/systemd/system/dnsmasq.service

    # Ensure dnsmasq returns system IP and not IP of loop-back device 127.0.1.1
    sudo sed -i 's/^#no-hosts$/no-hosts/g' /etc/dnsmasq.conf

    # Update Wildcard DNS Entry for kx-as-code.local
    echo "address=/kx-main/$IP_ADDRESS" | sudo tee /etc/dnsmasq.d/kx-as-code.local.conf
    sudo systemctl enable --now dnsmasq.service
    sudo systemctl enable systemd-networkd-wait-online.service
fi
