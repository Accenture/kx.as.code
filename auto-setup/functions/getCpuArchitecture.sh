getCpuArchitecture() {
  # Determine CPU architecture
  if [[ -n $( uname -a | grep "aarch64") ]]; then
    export cpuArchitecture="arm64"
  else
    export cpuArchitecture="amd64"
  fi
}