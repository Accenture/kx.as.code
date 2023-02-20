calculateDuration() {

    local functionStartEpochTimestamp=${1}
    local functionEndEpochTimestamp=${2}

    local functionDuration=$(echo "${functionEndEpochTimestamp} - ${functionStartEpochTimestamp}" | bc)
    local durationDays=$(echo "${functionDuration}/86400" | bc)
    local durationTimestamp2=$(echo "${functionDuration}-86400*${durationDays}" | bc)
    local durationHours=$(echo "${durationTimestamp2}/3600" | bc)
    local durationTimestamp3=$(echo "${durationTimestamp2}-3600*${durationHours}" | bc)
    local durationMinutes=$(echo "${durationTimestamp3}/60" | bc)
    local durationSeconds=$(echo "${durationTimestamp3}-60*${durationMinutes}" | bc)

    #LC_NUMERIC=C printf "%d:%02d:%02d:%02.4f" ${durationDays} ${durationHours} ${durationMinutes} ${durationSeconds}
    LC_NUMERIC=C printf "%d day %02d hours %02d minutes %02.4f seconds" ${durationDays} ${durationHours} ${durationMinutes} ${durationSeconds}

}