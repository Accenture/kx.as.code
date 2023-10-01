####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
calculateDuration() {

    echo "${FUNCNAME[0]}()" >${installationWorkspace}/.currentFunctionExecuting

    local functionStartEpochTimestamp=${1}
    local functionEndEpochTimestamp=${2}

    local functionDuration=$(echo "${functionEndEpochTimestamp} - ${functionStartEpochTimestamp}" | bc)
    local durationDays=$(echo "${functionDuration}/86400" | bc)
    local durationTimestamp2=$(echo "${functionDuration}-86400*${durationDays}" | bc)
    local durationHours=$(echo "${durationTimestamp2}/3600" | bc)
    local durationTimestamp3=$(echo "${durationTimestamp2}-3600*${durationHours}" | bc)
    local durationMinutes=$(echo "${durationTimestamp3}/60" | bc)
    local durationSeconds=$(echo "${durationTimestamp3}-60*${durationMinutes}" | bc)

    if [[ "${durationDays}" -gt 0 ]]; then
       LC_NUMERIC=C printf "%d day %02d hours %02d minutes %02.0f seconds" "${durationDays}" "${durationHours}" "${durationMinutes}" "${durationSeconds}"
    elif [[ "${durationHours}" -gt 0 ]]; then
       LC_NUMERIC=C printf "%02d hours %02d minutes %02.0f seconds" "${durationHours}" "${durationMinutes}" "${durationSeconds}"
    elif [[ "${durationMinutes}" -gt 0 ]]; then
       LC_NUMERIC=C printf "%02d minutes %02.0f seconds" "${durationMinutes}" "${durationSeconds}"
    elif [[ $(echo "${durationSeconds}" | cut -d"$(locale decimal_point)" -f1) -gt 0 ]]; then
       LC_NUMERIC=C printf "%02.0f seconds" "${durationSeconds}"
    else
      log_debug "Was not able to calculate a duration. Probably not an issue, but sending a debug message just in case"
    fi

    log_debug "Exiting calculateDuration() with rc=$?"

}
