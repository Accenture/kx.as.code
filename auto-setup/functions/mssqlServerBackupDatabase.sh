mssqlServerBackupDatabase() {
        
    local mssqlServerIp=${1:-}
    local mssqlServerGoPassCredentialName=${2:-}
    local mssqlServerGoPassCredentiaGroup=${3:-}
    local mssqlServerSourceDatabase=${4:-}
    local mssqlServerBackupWithTimestamp=${5:-}

   if [[ "${mssqlServerBackupWithTimestamp}" == "true" ]]; then
      databaseBackupTimestamp="_$(date +%d%m%Y_%H%M%S)"
   else
      databaseBackupTimestamp=""
   fi

    # Ensure all needded parameters have been passed to function
    if [[ -n ${mssqlServerIp} ]] && [[ -n ${mssqlServerGoPassCredentialName} ]] && [[ -n ${mssqlServerGoPassCredentiaGroup} ]] && [[ -n ${mssqlServerSourceDatabase} ]]; then

    # Get MSSQL SA password
    local mssqlSaPassword="$(managedPassword "${mssqlServerGoPassCredentialName}" "${mssqlServerGoPassCredentiaGroup}")"

    /opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp} -Q "BACKUP DATABASE ${mssqlServerSourceDatabase} TO DISK ='/var/opt/mssql/backups/${mssqlServerSourceDatabase}${databaseBackupTimestamp}.bak' WITH INIT" -U sa -P ${mssqlSaPassword}

     else
        log_info "Please provide all needed parameters when calling mssqlServerRestoreDatabaseWithNewDbName()"
     fi
}