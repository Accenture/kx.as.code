mssqlServerCloneDatabase() {
        
    local mssqlServerIp=${1:-}
    local mssqlServerGoPassCredentialName=${2:-}
    local mssqlServerGoPassCredentiaGroup=${3:-}
    local mssqlServerSourceDatabase=${4:-}
    local mssqlServerTargetDatabase=${5:-}

    # Ensure all needded parameters have been passed to function
    if [[ -n ${mssqlServerIp} ]] && [[ -n ${mssqlServerGoPassCredentialName} ]] && [[ -n ${mssqlServerGoPassCredentiaGroup} ]] && [[ -n ${mssqlServerSourceDatabase} ]] && [[ -n ${mssqlServerTargetDatabase} ]]; then

        # Back up source database to use during restore
        mssqlServerBackupDatabase \
            ${mssqlServerIp} \
            ${mssqlServerGoPassCredentialName} \
            ${mssqlServerGoPassCredentiaGroup} \
            ${mssqlServerSourceDatabase}

        # Restore database under new name backed up above
        mssqlServerRestoreDatabaseWithNewDbName \
            ${mssqlServerIp} \
            ${mssqlServerGoPassCredentialName} \
            ${mssqlServerGoPassCredentiaGroup} \
            ${mssqlServerSourceDatabase} \
            ${mssqlServerTargetDatabase}
     
     else
        log_info "Please provide all needed parameters when calling mssqlServerCloneDatabase()"
     fi
}