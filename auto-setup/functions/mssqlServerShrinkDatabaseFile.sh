mssqlServerShrinkDatabaseFile() {

    local mssqlServerIp=${1:-}
    local mssqlServerGoPassCredentialName=${2:-}
    local mssqlServerGoPassCredentiaGroup=${3:-}
    local mssqlServerDatabaseSourceDatabase=${4:-}

    # Ensure all needded parameters have been passed to function
    if [[ -n ${mssqlServerIp} ]] && [[ -n ${mssqlServerGoPassCredentialName} ]] && [[ -n ${mssqlServerGoPassCredentiaGroup} ]] && [[ -n ${mssqlServerSourceDatabase} ]]; then

        # Get MSSQL SA password
        local mssqlSaPassword="$(managedPassword "${mssqlServerGoPassCredentialName}" "${mssqlServerGoPassCredentiaGroup}")"

        # Get DB log filename
        local hybrisDbLogFilename=$(/opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp} -U sa -P ${mssqlSaPassword} -h -1 \
            -Q "USE ${mssqlServerDatabaseSourceDatabase}; SET NOCOUNT ON; SELECT name from sys.master_files WHERE database_id = db_id() AND type = 1" | tail -1)

        # Create SQL file for shrink pod MSSQL database File
        echo """USE [${mssqlServerDatabaseSourceDatabase}]
        GO
        ALTER DATABASE ${mssqlServerDatabaseSourceDatabase} SET RECOVERY SIMPLE
        GO
        DBCC SHRINKFILE (${hybrisDbLogFilename}, 1)
        GO
        ALTER DATABASE ${mssqlServerDatabaseSourceDatabase} SET RECOVERY FULL
        GO
        :On Error exit
        """ | sed 's/^        //g' | sudo tee ${installationWorkspace}/mssql_shrink_${mssqlServerDatabaseSourceDatabase}_database.sql

        # Execute shrink of MSSQL database File
        /opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp} -U sa -P ${mssqlSaPassword} \
            -i  ${installationWorkspace}/mssql_shrink_${mssqlServerDatabaseSourceDatabase}_database.sql

     else
        log_info "Please provide all needed parameters when calling mssqlServerShrinkDatabaseFile()"
     fi

}