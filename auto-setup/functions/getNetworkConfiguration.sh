getNetworkConfiguration() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  # Determine which NIC to bind to, to avoid binding to internal VirtualBox NAT NICs for example, where all hosts have the same IP - 10.0.2.15
  export nicList=$(nmcli device show | grep -E 'enp|ens|eth0' | grep 'GENERAL.DEVICE' | awk '{print $2}')
  export ipsToExclude="10.0.2.15"   # IP addresses not to configure with static IP. For example, default Virtualbox IP 10.0.2.15
  export nicExclusions=""
  export excludeNic=""
  for nic in ${nicList}; do
      for ipToExclude in ${ipsToExclude}; do
          ip=$(ip a s ${nic} | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2 || true)
          echo ${ip}
          if [[ ${ip} == "${ipToExclude}" ]]; then
              excludeNic="true"
          fi
      done
      if [[ ${excludeNic} == "true" ]]; then
          echo "Excluding NIC ${nic}"
          nicExclusions="${nicExclusions} ${nic}"
          excludeNic="false"
      else
          export netDevice=${nic}
      fi
  done
  echo "NIC exclusions: ${nicExclusions}"
  echo "NIC to use: ${netDevice}"

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
