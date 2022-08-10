installEnvhandlebars() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  export nvmVersionSelectedAlias="$(cat /usr/local/nvm/alias/$(cat /usr/local/nvm/alias/default))"
  export nvmVersionSelectedPath="/usr/local/nvm/versions/node/${nvmVersionSelectedAlias}/bin"

  # Check if node reachable
  export nodeToolPath=$(which node || true)
  if [ -x "$nodeToolPath" ] ; then
      echo "node found on path $nodeToolPath"
  else

      echo "node not found on path, adding it"
      export PATH=$(dirname $(find ${nvmVersionSelectedPath} -type f -executable -name "node")):$PATH
  fi

  # Check if envhandlebars reachable
  export envhandlebarsToolPath=$(which envhandlebars || true)
  echo $envhandlebarsToolPath
  if [ -x "$envhandlebarsToolPath" ] ; then
      echo "envhandlebars found on path $envhandlebarsToolPath"
  else
      echo "envhandlebars not found on path, adding it"
      export PATH=$(dirname $(find ${nvmVersionSelectedPath} -type f -executable -name "envhandlebars")):$PATH
  fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}