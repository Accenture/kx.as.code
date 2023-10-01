guacamoleAssignAdminPermissions() {

  local username=${1}

  # Retrieve MariaDB Password
  local mariadbAdminPassword=$(managedPassword "mariadb-admin-password" "remote-desktop")

  # Assign system admin privileges to user
  echo """
  -- Grant this user all system permissions
  INSERT IGNORE INTO guacamole_system_permission (entity_id, permission)
  SELECT entity_id, permission
  FROM (
            SELECT '${username}'  AS username, 'CREATE_CONNECTION'       AS permission
      UNION SELECT '${username}'  AS username, 'CREATE_CONNECTION_GROUP' AS permission
      UNION SELECT '${username}'  AS username, 'CREATE_SHARING_PROFILE'  AS permission
      UNION SELECT '${username}'  AS username, 'CREATE_USER'             AS permission
      UNION SELECT '${username}'  AS username, 'CREATE_USER_GROUP'       AS permission
      UNION SELECT '${username}'  AS username, 'ADMINISTER'              AS permission
  ) permissions
  JOIN guacamole_entity ON permissions.username = guacamole_entity.name AND guacamole_entity.type = 'USER'
  """ | /usr/bin/sudo mysql --password="${mariadbAdminPassword}" guacamole_db

}