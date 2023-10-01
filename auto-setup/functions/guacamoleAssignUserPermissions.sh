guacamoleAssignUserPermissions() {

  local username=${1}

  # Retrieve MariaDB Password
  local mariadbAdminPassword=$(managedPassword "mariadb-admin-password" "remote-desktop")

  # Assign user privileges to user
  echo """
  -- Grant admin permission to read/update/administer self
  INSERT IGNORE INTO guacamole_user_permission (entity_id, affected_user_id, permission)
  SELECT guacamole_entity.entity_id, guacamole_user.user_id, permission
  FROM (
            SELECT '${username}' AS username, '${username}' AS affected_username, 'READ'       AS permission
      UNION SELECT '${username}' AS username, '${username}' AS affected_username, 'UPDATE'     AS permission
      UNION SELECT '${username}' AS username, '${username}' AS affected_username, 'ADMINISTER' AS permission
  ) permissions
  JOIN guacamole_entity          ON permissions.username = guacamole_entity.name AND guacamole_entity.type = 'USER'
  JOIN guacamole_entity affected ON permissions.affected_username = affected.name AND guacamole_entity.type = 'USER'
  JOIN guacamole_user            ON guacamole_user.entity_id = affected.entity_id
  """ | /usr/bin/sudo mysql --password="${mariadbAdminPassword}" guacamole_db

}