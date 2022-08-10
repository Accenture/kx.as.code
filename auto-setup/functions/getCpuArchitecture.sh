getCpuArchitecture() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  # Determine CPU architecture
  if [[ -n $( uname -a | grep "aarch64") ]]; then
    export cpuArchitecture="arm64"
  else
    export cpuArchitecture="amd64"
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}