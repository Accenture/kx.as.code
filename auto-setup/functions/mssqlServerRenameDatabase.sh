mssqlServerRenameDatabase() {

    local mssqlServerIp=${1:-}
    local mssqlServerGoPassCredentialName=${2:-}
    local mssqlServerGoPassCredentiaGroup=${3:-}
    local mssqlServerDatabaseSourceDatabase=${4:-}
    local mssqlServerDatabaseTargetDatabase=${5:-}

    # Ensure all needded parameters have been passed to function
    if [[ -n ${mssqlServerIp} ]] && [[ -n ${mssqlServerGoPassCredentialName} ]] && [[ -n ${mssqlServerGoPassCredentiaGroup} ]] && [[ -n ${mssqlServerSourceDatabase} ]] && [[ -n ${mssqlServerTargetDatabase} ]]; then

        # Get MSSQL SA password
        local mssqlSaPassword="$(managedPassword "${mssqlServerGoPassCredentialName}" "${mssqlServerGoPassCredentiaGroup}")"

        # Put databse offline
        /opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp} -Q "ALTER DATABASE ${mssqlServerDatabaseSourceDatabase} SET OFFLINE WITH ROLLBACK IMMEDIATE" -U sa -P ${mssqlSaPassword}

        # Execute Rename
        echo """/* Put database in single user mode */
        USE [master]
        GO
        ALTER DATABASE [${mssqlServerDatabaseSourceDatabase}] SET ONLINE;
        GO
        ALTER DATABASE [${mssqlServerDatabaseSourceDatabase}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
        GO
        /* Rename database */
        ALTER DATABASE [${mssqlServerDatabaseSourceDatabase}] MODIFY FILE (NAME = '${mssqlServerDatabaseSourceDatabase}', FILENAME = '/var/opt/mssql/data/${mssqlServerDatabaseTargetDatabase}.mdf')
        ALTER DATABASE [${mssqlServerDatabaseSourceDatabase}] MODIFY FILE (NAME = '${mssqlServerDatabaseSourceDatabase}_log', FILENAME = '/var/opt/mssql/data/${mssqlServerDatabaseTargetDatabase}_log.ldf')
        ALTER DATABASE [${mssqlServerDatabaseSourceDatabase}] MODIFY FILE (NAME = ${mssqlServerDatabaseSourceDatabase}, NEWNAME = ${mssqlServerDatabaseTargetDatabase})
        ALTER DATABASE [${mssqlServerDatabaseSourceDatabase}] MODIFY FILE (NAME = ${mssqlServerDatabaseSourceDatabase}_log, NEWNAME = ${mssqlServerDatabaseTargetDatabase}_log)
        GO
        :On Error exit
        """ | sed 's/^        //g' | sudo tee ${installationWorkspace}/renameDatabasePart1.sql

        # Execute rename DB SQL script part 1
        /opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp} -U sa -P ${mssqlSaPassword} \
            -i ${installationWorkspace}/renameDatabasePart1.sql

        # Set DB to offlie status for renaming phyisical files
        /opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp}  -Q 'ALTER DATABASE hybris SET OFFLINE' -U sa -P ${mssqlSaPassword}

        # Rename phyisical files
        # Get MSSQL server pod name
        mssqlServerPod=$(sudo kubectl get pods -n "${namespace}" -l app="mssql-server" -o json | jq -r '.items[].metadata.name' || true)

        # Rename phyisical filenames if target not already exiting
        targetFilenameAlreadyExists=$(kubectl exec ${mssqlServerPod} -n "${namespace}" \
            -- bash -c "find /var/opt/mssql/data/ -name \"${mssqlServerDatabaseTargetDatabase}.mdf\"")
        if [[ -z "${targetFilenameAlreadyExists}" ]]; then
        kubectl exec ${mssqlServerPod} -n "${namespace}" \
            -- bash -c "mv /var/opt/mssql/data/${mssqlServerDatabaseSourceDatabase}.mdf /var/opt/mssql/data/${mssqlServerDatabaseTargetDatabase}.mdf"
        fi

        # Rename phyisical filenames if target not already exiting
        targetFilenameAlreadyExists=$(kubectl exec ${mssqlServerPod} -n "${namespace}" \
            -- bash -c "find /var/opt/mssql/data/ -name \"${mssqlServerDatabaseTargetDatabase}_log.ldf\"")
        if [[ -z "${targetFilenameAlreadyExists}" ]]; then
        kubectl exec ${mssqlServerPod} -n "${namespace}" \
            -- bash -c "mv /var/opt/mssql/data/${mssqlServerDatabaseSourceDatabase}_log.ldf /var/opt/mssql/data/${mssqlServerDatabaseTargetDatabase}_log.ldf"
        fi

        echo """/* Put database online */
        USE [master]
        GO
        ALTER DATABASE [${mssqlServerDatabaseSourceDatabase}] SET ONLINE
        GO
        /* Rename database */
        ALTER DATABASE [${mssqlServerDatabaseSourceDatabase}] MODIFY NAME = ${mssqlServerDatabaseTargetDatabase}
        GO
        /* Put database in multi user mode */
        ALTER DATABASE [${mssqlServerDatabaseTargetDatabase}] SET MULTI_USER
        GO
        :On Error exit
        """ | sed 's/^        //g' | sudo tee ${installationWorkspace}/renameDatabasePart2.sql

        # Execute rename DB SQL script part 2
        /opt/mssql-tools/bin/sqlcmd -S ${mssqlServerIp} -U sa -P ${mssqlSaPassword} \
            -i ${installationWorkspace}/renameDatabasePart2.sql

     else
        log_info "Please provide all needed parameters when calling mssqlServerRestoreDatabaseWithNewDbName()"
     fi

}