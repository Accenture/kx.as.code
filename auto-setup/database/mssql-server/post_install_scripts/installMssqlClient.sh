#!/bin/bash -x

# Get Microsoft Repo Details
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/debian/11//prod.list > /etc/apt/sources.list.d/microsoft-prod.list

# Install MSSQL Client
/usr/bin/sudo apt-get update
/usr/bin/sudo ACCEPT_EULA=Y apt-get install -y msodbcsql17
/usr/bin/sudo ACCEPT_EULA=Y apt-get install -y mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' | tee -a /root/.bashrc /home/${baseUser}/.bashrc /root/.zshrc /home/${baseUser}/.zshrc
source ~/.bashrc

# Get MSSQL Kubernetes Service Load Balancer IP Address
export mssqlServiceLoadBalancerIp="$(kubernetesGetServiceLoadBalancerIp "mssql-server-service")"

# Check if MSSQL Server is responding
mssqlServerPassword="$(managedPassword "mssql-server-sa-password" "mssql-server")"
mssqlClientResponse=$(sqlcmd -S ${mssqlServiceLoadBalancerIp} -U sa -P ${mssqlServerPassword} -Q "SELECT @@VERSION")
for i in {1..10}
do
    if [[ -n "$(echo "${mssqlClientResponse}" | grep "(1 rows affected)")" ]]; then
        log_info "MSSQL Server is up:\n${mssqlClientResponse}"
        break
    else
        log_warn "MSSQL Server not yet accessible. Checking again in 15 seconds:\n${mssqlClientResponse}"
        sleep 15
    fi
done