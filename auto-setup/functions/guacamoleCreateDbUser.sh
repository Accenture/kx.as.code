guacamoleCreateDbUser() {

  local username=${1}

  # Retrieve/Generate User Password
  if [[ "${username}" == "guacadmin" ]]; then
    local userPassword=$(managedPassword "guacamole-admin-password" "remote-desktop")
  else
    local userPassword=$(managedPassword "user-${username}-password" "users")
  fi

  # Retrieve MariaDB Password
  local mariadbAdminPassword=$(managedPassword "mariadb-admin-password" "remote-desktop")

  # Create new Guacamole Remote Desktop user
  echo """
  SET @salt = UNHEX(SHA2(UUID(), 256));

  INSERT IGNORE INTO guacamole_entity (name, type) VALUES ('${username}', 'USER');
  INSERT IGNORE INTO guacamole_user (entity_id, password_hash, password_salt, password_date)
  SELECT
      entity_id,
      @salt,
      UNHEX(SHA2(CONCAT('${userPassword}', HEX(@salt)), 256)),
      NOW()
  FROM guacamole_entity WHERE name = '${username}'
  """ | /usr/bin/sudo mysql --password="${mariadbAdminPassword}" guacamole_db

}
