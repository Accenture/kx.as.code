getGlobalVariables() {
    OLDIFS=$IFS
    IFS="§"
    # Set environment variables if set in globalVariables.json
    globalVariables=$(cat globalVariables.json | jq -r '. | to_entries|map("\(.key)=\(.value|tostring)§")|.[]' )
    if [[ -n ${globalVariables} ]]; then
        for environmentVariable in ${globalVariables}; do
            envVarName="$(echo ${environmentVariable} | cut -f1 -d= | tr -d '\n\r' | tr -d '§')"
            envVarValue="$(echo ${environmentVariable} | cut -f2 -d= | tr -d '\n\r' | tr -d '§')"
            echo export ${envVarName}=''$(eval echo ${envVarValue})''
            export ${envVarName}=''$(eval echo ${envVarValue})''
        done
    fi
    IFS=$OLDIFS
}