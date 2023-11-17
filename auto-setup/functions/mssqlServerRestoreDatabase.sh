mssqlServerRestoreDatabase() {
        
    local mssqlServerIp=${1:-}
    local mssqlServerGoPassCredentialName=${2:-}
    local mssqlServerGoPassCredentiaGroup=${3:-}
    local mssqlServerSourceDatabase=${4:-}
    local backupFileTimestamp=${5:-}

    if [[ -n ${backupFileTimestamp} ]]; then
         backupFileToRestore="${mssqlServerSourceDatabase}_${backupFileTimestamp}.bak"
    else
         backupFileToRestore="${mssqlServerSourceDatabase}.bak"
    fi

    # Ensure all needded parameters have been passed to function
    if [[ -n ${mssqlServerIp} ]] && [[ -n ${mssqlServerGoPassCredentialName} ]] && [[ -n ${mssqlServerGoPassCredentiaGroup} ]] && [[ -n ${mssqlServerSourceDatabase} ]]; then

        # Get MSSQL SA password
        local mssqlSaPassword="$(managedPassword "${mssqlServerGoPassCredentialName}" "${mssqlServerGoPassCredentiaGroup}")"

         # Put databse offline
        /opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp} -Q "ALTER DATABASE ${mssqlServerSourceDatabase} SET OFFLINE WITH ROLLBACK IMMEDIATE" -U sa -P ${mssqlSaPassword}

        # Restore MS SQL database
        /opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp} -Q "RESTORE DATABASE ${mssqlServerSourceDatabase} FROM DISK ='/var/opt/mssql/backups/${backupFileToRestore}' WITH REPLACE" -U sa -P ${mssqlSaPassword}

        # Make database online again
        /opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp} -Q "ALTER DATABASE ${mssqlServerSourceDatabase} SET ONLINE" -U sa -P ${mssqlSaPassword}

     else
        log_info "Please provide all needed parameters when calling mssqlServerRestoreDatabase()"
     fi

}