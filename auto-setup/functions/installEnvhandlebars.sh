installEnvhandlebars() {
  # Check if envhandlebars tool reachable
  nodeToolPath=$(which node || true)
  if [ -x "$nodeToolPath" ] ; then
      echo "node found on path $nodeToolPath"
  else
      echo "envhandlebars not found on path, adding it"
      export PATH=$(dirname $(find $HOME -type f -executable -name "node")):$PATH
  fi
}
