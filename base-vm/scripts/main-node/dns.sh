#!/bin/bash -x
set -euo pipefail

# Install Bind9 for local DNS resolution
# TODO - Re-enable systemd-resolved for Debian 12
sudo apt install -y bind9 bind9utils bind9-doc #systemd-resolved
#sudo systemctl enable systemd-resolved

echo '''options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0s placeholder.

        // forwarders {
        //      0.0.0.0;
        // };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        dnssec-validation auto;
        auth-nxdomain no;
        listen-on-v6 { any; };
        allow-query { any; };
        version "not currently available";
        recursion yes;
        querylog no;
        allow-transfer { none; };

};''' | sudo tee /etc/bind/named.conf.options
