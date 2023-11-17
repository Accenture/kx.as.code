mssqlServeCheckDbExists() {
        
    local mssqlServerIp=${1:-}
    local mssqlServerGoPassCredentialName=${2:-}
    local mssqlServerGoPassCredentiaGroup=${3:-}
    local mssqlServerSourceDatabase=${4:-}

    # Ensure all needded parameters have been passed to function
    if [[ -n ${mssqlServerIp} ]] && [[ -n ${mssqlServerGoPassCredentialName} ]] && [[ -n ${mssqlServerGoPassCredentiaGroup} ]] && [[ -n ${mssqlServerSourceDatabase} ]]; then

    # Get MSSQL SA password
    local mssqlSaPassword="$(managedPassword "${mssqlServerGoPassCredentialName}" "${mssqlServerGoPassCredentiaGroup}")"
   
    # Check if database exists
    /opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp} -Q 'IF DB_ID("'${mssqlServerSourceDatabase}'") IS NOT NULL print "EXISTS";' -U sa -P ${mssqlSaPassword}

     else
        log_info "Please provide all needed parameters when calling mssqlServeCheckDbExists()"
     fi
}