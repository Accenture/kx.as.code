guacamoleAssignUserXrpConnection() {

  local username=${1}

  # Retrieve MariaDB Password
  local mariadbAdminPassword=$(managedPassword "mariadb-admin-password" "remote-desktop")

  # Assign XRDP connection group permission to user in Guacamole database
  echo """
  INSERT IGNORE INTO guacamole_connection_group_permission(entity_id, connection_group_id, permission)
  VALUES (
  (SELECT entity_id FROM guacamole_entity WHERE name = '${username}'),
  (SELECT connection_group_id FROM guacamole_connection_group WHERE connection_group_name = 'kx-as-code'),
  'READ'
  );
  """ | /usr/bin/sudo mysql --password="${mariadbAdminPassword}" guacamole_db

  # Assign XRDP connection permission to user in Guacamole database
  echo """
  INSERT IGNORE INTO guacamole_connection_permission(entity_id, connection_id, permission)
  VALUES (
  (SELECT entity_id FROM guacamole_entity WHERE name = '${username}'),
  (SELECT connection_id FROM guacamole_connection WHERE connection_name = 'rdp'),
  'READ'
  );
  """ | /usr/bin/sudo mysql --password="${mariadbAdminPassword}" guacamole_db

}