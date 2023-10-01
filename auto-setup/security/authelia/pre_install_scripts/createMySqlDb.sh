#!/bin/bash

# Get mariadb server admin password
export mariadbAdminPassword=$(managedPassword "mariadb-admin-password" "remote-desktop")

# Create mariadb server user password for Authelia
export mariadbAutheliaPassword=$(managedPassword "mariadb-authelia-password" "authelia")

# Add MariaDB setting needed by Authelia
/usr/bin/sudo sed -i '/^\[mysqld\]$/a explicit_defaults_for_timestamp = ON' /etc/mysql/mariadb.conf.d/50-server.cnf
/usr/bin/sudo systemctl restart mariadb.service

# Create Database (Core Remote Desktop component must be installed first, as it provides the MySQL DB server)
echo "CREATE DATABASE IF NOT EXISTS authelia;" | /usr/bin/sudo mysql --password="${mariadbAdminPassword}"

# Create user permissions and grant priviliges
echo "DROP USER IF EXISTS 'authelia'@'%';" | /usr/bin/sudo mysql --password="${mariadbAdminPassword}" authelia
echo "CREATE USER 'authelia'@'%' IDENTIFIED BY '${mariadbAutheliaPassword}';" | /usr/bin/sudo mysql --password="${mariadbAdminPassword}" authelia
echo "GRANT ALL PRIVILEGES ON authelia.* TO 'authelia'@'%' IDENTIFIED BY '${mariadbAutheliaPassword}';" | /usr/bin/sudo mysql --password="${mariadbAdminPassword}" authelia
#echo "GRANT ALL PRIVILEGES ON authelia.* TO 'authelia'@'%' IDENTIFIED BY '${mariadbAutheliaPassword}';"  | /usr/bin/sudo mysql --password="${mariadbAdminPassword}" authelia

echo "FLUSH PRIVILEGES;" | /usr/bin/sudo mysql --password="${mariadbAdminPassword}" authelia
