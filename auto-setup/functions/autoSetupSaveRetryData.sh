autoSetupSaveRetryData() {

    # This script saves the data needed to restart an installation from where it last errored

    local phaseId=${1}
    local installPhase=${2}
    local script=${3}
    local escapedPayload=$(echo ${4} | sed -E 's/([^\]|^)"/\1\\"/g')
    
    local retryDataStore='{ "phase_id": "'${phaseId}'", "install_phase": "'${installPhase}'", "script":"'${script}'", "payload": "'${escapedPayload}'" }' 
    log_debug "retryDataStore: ${retryDataStore}"

    cleanOutput "${retryDataStore}" >${installationWorkspace}/.retryDataStore.json
    
}
