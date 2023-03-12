updateHostFileForExternalUse() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  # Check if "externalAccessDirectory" directory exists and create if not
  createExternalAccessDirectory

  # Generate hosts entry so that user can copy it to their /etc/hosts /Linux/Mac) or to C:\Windows\System32\drivers\etc\hosts on Windows
  local ingressTlsUrls=$(kubectl get ingress --all-namespaces -o json | jq -r '"\(.items[].spec.tls[]?.hosts[])"' | sort | uniq | tr '\n' ' ')
  echo "# Copy and paste the below hosts entry (append to your source file, do not replace it with this one!) to your host machine to be able to access provisioned applications/urls externally" | /usr/bin/sudo tee ${externalAccessDirectory}/hosts
  echo "# Linux/Mac: /etc/hosts" | /usr/bin/sudo tee -a ${externalAccessDirectory}/hosts
  echo "# Windows: C:\Windows\System32\drivers\etc\hosts" | /usr/bin/sudo tee -a ${externalAccessDirectory}/hosts
  echo -e "\n" | /usr/bin/sudo tee -a ${externalAccessDirectory}/hosts

  if [[ "${virtualizationType}" != "public-cloud" ]]; then
    local lbExternalIpAddress="127.0.0.1"
  else
    local lbExternalIpAddress="$(curl -s ifconfig.me)"
  fi

  echo "${lbExternalIpAddress}       ${ingressTlsUrls}" | /usr/bin/sudo tee -a ${externalAccessDirectory}/hosts

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}