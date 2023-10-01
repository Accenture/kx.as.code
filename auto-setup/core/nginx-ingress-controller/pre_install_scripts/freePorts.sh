#!/bin/bash

# Temporary workaround to prevent later failures
# TODO: Find a better solution in future. Check again whether Apache can be removed without breaking something
if [[ -f /etc/apache2/ports.conf ]]; then
  if [[ -z $(grep "8081" /etc/apache2/sites-available/000-default.conf) ]]; then
      sed -i 's/:80/:8081/g' /etc/apache2/sites-available/000-default.conf
  fi
  if [[ -z $(grep "8081" /etc/apache2/ports.conf) ]]; then
      sed -i 's/Listen 80/Listen 8081/g' /etc/apache2/ports.conf
  fi
  if [[ -z $(grep "4481" /etc/apache2/ports.conf) ]]; then
      sed -i 's/Listen 443/Listen 4481/g' /etc/apache2/ports.conf
  fi
  systemctl restart apache2
  systemctl status apache2.service
fi

