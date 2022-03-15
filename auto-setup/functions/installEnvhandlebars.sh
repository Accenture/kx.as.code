installEnvhandlebars() {

  # Check if node reachable
  export nodeToolPath=$(which node || true)
  if [ -x "$nodeToolPath" ] ; then
      echo "node found on path $nodeToolPath"
  else
      echo "envhandlebars not found on path, adding it"
      export PATH=$(dirname $(find $HOME -type f -executable -name "node")):$PATH
  fi

  # Check if envhandlebars reachable
  export envhandlebarsToolPath=$(which envhandlebars || true)
  echo $envhandlebarsToolPath
  if [ -x "$envhandlebarsToolPath" ] ; then
      echo "envhandlebars found on path $envhandlebarsToolPath"
  else
      echo "envhandlebars not found on path, adding it"
      export PATH=$(dirname $(find $HOME -type f -executable -name "envhandlebars")):$PATH
  fi

}
