#!/usr/bin/env expect
set bitwardenHomeDir [lindex $argv 0];
set bitwardenDomain [lindex $argv 1];
spawn -noecho ${bitwardenHomeDir}/bitwarden.sh install
expect "Enter the domain name for your Bitwarden instance (ex. bitwarden.example.com): " { send -- "${bitwardenDomain}\r" }
expect "Do you want to use Let's Encrypt to generate a free SSL certificate? (y/n): " { send -- "n\r" }
expect "Enter the database name for your Bitwarden instance (ex. vault): " { send -- "vault\r" }
interact
