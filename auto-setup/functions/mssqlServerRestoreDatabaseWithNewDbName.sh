mssqlServerRestoreDatabaseWithNewDbName() {
        
    local mssqlServerIp=${1:-}
    local mssqlServerGoPassCredentialName=${2:-}
    local mssqlServerGoPassCredentiaGroup=${3:-}
    local mssqlServerDatabaseSourceDatabase=${4:-}
    local mssqlServerDatabaseTargetDatabase=${5:-}

    # Ensure all needded parameters have been passed to function
    if [[ -n ${mssqlServerIp} ]] && [[ -n ${mssqlServerGoPassCredentialName} ]] && [[ -n ${mssqlServerGoPassCredentiaGroup} ]] && [[ -n ${mssqlServerSourceDatabase} ]] && [[ -n ${mssqlServerTargetDatabase} ]]; then

        # Get MSSQL SA password
        local mssqlSaPassword="$(managedPassword "${mssqlServerGoPassCredentialName}" "${mssqlServerGoPassCredentiaGroup}")"

        # Get logical names
        local logicalDataName=$(/opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp} -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backups/${mssqlServerDatabaseSourceDatabase}.bak';" -U sa -P ${mssqlSaPassword} | tr -s ' ' | cut -d' ' -f1,2,3,4,5 | tail -n +3 | head -n -2 | head -1 | awk {'print $1'})
        local logicalLogName=$(/opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp} -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backups/${mssqlServerDatabaseSourceDatabase}.bak';" -U sa -P ${mssqlSaPassword} | tr -s ' ' | cut -d' ' -f1,2,3,4,5 | tail -n +3 | head -n -2 | tail  -1 | awk {'print $1'})

        # Execute Restore
        /opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp} -Q "RESTORE DATABASE ${mssqlServerDatabaseTargetDatabase} \
            FROM DISK ='/var/opt/mssql/backups/${mssqlServerDatabaseSourceDatabase}.bak' \
            WITH MOVE '${logicalDataName}' TO '/var/opt/mssql/data/${mssqlServerDatabaseTargetDatabase}.mdf', \
            MOVE '${logicalLogName}' TO '/var/opt/mssql/data/${mssqlServerDatabaseTargetDatabase}_log.ldf'" \
            -U sa -P ${mssqlSaPassword}

     else
        log_info "Please provide all needed parameters when calling mssqlServerRestoreDatabaseWithNewDbName()"
     fi

}