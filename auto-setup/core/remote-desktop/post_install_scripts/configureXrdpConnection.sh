#!/bin/bash

if [[ -z $(which raspinfo) ]]; then

# Create and configure XRDP connection in Guacamole database
mariadbAdminPassword=$(managedPassword "mariadb-admin-password" "remote-desktop")
if [[ -z "$(echo "select connection_group_name from guacamole_connection_group where connection_group_name = 'kx-as-code'" | /usr/bin/sudo mysql -u root -sN --password="${mariadbAdminPassword}" guacamole_db)" ]]; then

echo """
INSERT INTO guacamole_connection(
        connection_name, protocol)
        VALUES ('rdp', 'rdp');

INSERT INTO guacamole_connection_group(
        connection_group_name, type)
        VALUES ('kx-as-code', 'ORGANIZATIONAL');

INSERT INTO guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'hostname', 'localhost');

INSERT INTO guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'port', '3389');

INSERT INTO guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'ignore-cert', 'true');

INSERT INTO guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'security', 'any');

INSERT INTO guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'disable-audio', 'true');

INSERT INTO guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'disable-security', 'false');

INSERT INTO guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'username', '\${GUAC_USERNAME}');

INSERT INTO guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'password', '\${GUAC_PASSWORD}');

""" | /usr/bin/sudo mysql --password="${mariadbAdminPassword}" guacamole_db

fi

# Restart services
systemctl restart tomcat${tomcatVersion}
systemctl restart guacd
systemctl restart xrdp.service
systemctl restart xrdp-sesman.service

fi
