autoSetupConfigureOutgoingSmtp() {

# Configure Exim4 SMTP server to allow outgoing email notifications
/usr/bin/sudo debconf-set-selections <<CONF
exim4-config    exim4/dc_eximconfig_configtype  select  internet site; mail is sent and received directly using SMTP
exim4-config    exim4/dc_other_hostnames string ''$(cat /etc/hosts | grep 127.0.1.1 | awk '{print $2}')''
exim4-config    exim4/dc_local_interfaces string '127.0.0.1 ; ::1'
exim4-config    exim4/mailname string ''${basedomain}''
exim4-config    exim4/dc_readhost string ''
exim4-config    exim4/dc_relay_domains string ''
exim4-config    exim4/dc_minimaldns boolean false
exim4-config    exim4/dc_relay_nets string ''
exim4-config    exim4/dc_smarthost string ''
exim4-config    exim4/use_split_config boolean false
exim4-config    exim4/hide_mailname boolean false
exim4-config    exim4/dc_localdelivery select mbox format in /var/mail/
CONF

/usr/bin/sudo dpkg-reconfigure -fnoninteractive exim4-config
/usr/bin/sudo systemctl restart exim4

}



