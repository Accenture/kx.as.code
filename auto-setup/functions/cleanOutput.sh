cleanOutput() {

    local output="${1}"

    # Remove control characters, that may for example, break parsing with jq
    local cleanedOutput=$(echo "${output}" | tr -d "[:cntrl:]")
    echo ${cleanedOutput}

}